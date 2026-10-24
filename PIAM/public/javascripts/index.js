/**
 * Created with JetBrains RubyMine.
 * User: leo
 * Date: 3/10/13
 * Time: 3:58 PM
 * To change this template use File | Settings | File Templates.
 */
schedule_sources = {};

/*----------------------------- download progress --------------------------------------------*/
// The download server computes the progress of each query (assays may run in
// parallel); the page reads it every 2 seconds (QueriesController#progress).
download_polls = {};

// Colours of a query run, as in QueriesHelper (RUN_LABELS / RUN_BARS).
var RUN_STYLES = {
    never: ["", ""], running: ["label-info", "progress-striped active"],
    complete: ["label-success", "progress-success"], partial: ["label-warning", "progress-warning"],
    failed: ["label-important", "progress-danger"], stopped: ["label-important", "progress-danger"],
    interrupted: ["label-important", "progress-danger"]
};
var BAR_CLASSES = "progress-striped active progress-success progress-warning progress-danger progress-info";

function set_bar_style(element, classes) {
    $(element).removeClass(BAR_CLASSES).addClass(classes);
}

// Download bar and "last run" cell once a run has ended.
function show_run_result(key, status, last_run) {
    var style = RUN_STYLES[status] || RUN_STYLES.never;
    set_bar_style("#progress-" + key, style[1]);
    $("#progressbar-" + key).css("width", status === "never" ? "0" : "100%");
    if (!last_run) { return; }
    var cell = $("#last-run-" + key).empty();
    cell.append($("<span></span>").addClass("label query-status " + style[0]).text(status === "never" ? "never run" : status));
    if (last_run.finished_at) { cell.append(" ").append($("<span class='muted query-finished-at'></span>").text("finished " + last_run.finished_at)); }
    if (last_run.summary) { cell.append(" ").append($("<span class='query-summary'></span>").text(last_run.summary)); }
}

function start_download_progress(channel, url) {
    var key = parseInt(channel);
    if (download_polls[key]) { return; }
    download_polls[key] = { url: url, idle: 0 };
    setTimeout(function () { poll_download(key); }, 2000);
}

function poll_download(key) {
    var poll = download_polls[key];
    if (!poll) { return; }
    $.getJSON(poll.url).done(function (p) {
        if (!download_polls[key]) { return; }
        var converting = show_conversions(key, p.conversions);
        if (p.running) {
            set_bar_style("#progress-" + key, RUN_STYLES.running[1]);
            $("#progressbar-" + key).css("width", p.percent + "%");
            $("#status-" + key).text("running");
            if (p.total_assays) {
                $("#query-info-" + key).text(p.completed_assays + " of " + p.total_assays + " assays (" + p.percent + "%)");
            }
        } else if (p.status === "idle" && poll.idle < 3) {
            poll.idle += 1; // the download may not have started yet
        } else {
            $("#status-" + key).text(p.status === "idle" ? "stop" : p.status);
            if (p.status === "complete") { $("#query-info-" + key).text("download complete"); }
            var result = p.last_run && p.last_run.status !== "running" ? p.last_run.status : p.status;
            show_run_result(key, result === "idle" ? "never" : result, p.last_run);
            if (!converting) {
                stop_download_progress(key);
                return;
            }
            // Download finished, 3D conversions still running: keep polling.
            if (!poll.ended) { poll.ended = true; stop_download_links(key); }
        }
        setTimeout(function () { poll_download(key); }, 2000);
    }).fail(function () {
        setTimeout(function () { poll_download(key); }, 5000);
    });
}

function start_see(key) {
    $("#status-" + key).text('running');
    $("#stop-" + key + "> label:first").hide();
    $("#stop-" + key + "> a:first").show();
    $("#start-" + key + "> label:first").show();
    $("#start-" + key + "> a:first").hide();
}

function get_key(event){
    return JSON.parse(event.data)["channel"];
}

// Second bar: 3D conversions queued by the download. Returns true while
// some are pending.
function show_conversions(key, c) {
    if (!c || !c.total) { return false; }
    var done = c.total - c.pending;
    var text = "3D conversions: " + c.done + " of " + c.total + " done";
    if (c.failed > 0) { text += ", " + c.failed + " failed"; }
    if (c.pending > 0) { text += ", " + c.pending + " pending (docking waits for them)"; }
    $("#conversion-" + key).show();
    $("#conversion-info-" + key).text(text);
    set_bar_style("#conversion-progress-" + key, c.pending > 0 ? "progress-info progress-striped active" :
                  (c.failed > 0 ? "progress-warning" : "progress-success"));
    $("#conversion-bar-" + key).css("width", (done * 100 / c.total) + "%");
    return c.pending > 0;
}

function stop_download_progress(key){
    stop_download_links(key);
    delete download_polls[key];
}

function stop_download_links(key){
    $("#start-" + key + "> label:first").hide();
    $("#stop-" + key + "> a:first").hide();
    $("#start-" + key + "> a:first").show();
    $("#stop-" + key + "> label:first").show();
}

/*----------------------------- service for schedule queries --------------------------------------------*/

function start_schedule_service(channel, dir){
    var key = parseInt(channel);
    var source = new EventSource(dir);
    schedule_sources[key] = source;

    source.addEventListener('remaining_time', remaining_time, false);
    source.addEventListener('stop', stop_schedule_service, false);
}

function remaining_time(event) {
    var obj = JSON.parse(event.data);
    var key = obj["channel"];
    if(obj['remaining_time'] > 0){
        $("#chrono-days-" + key).text(obj['time']["days"]);
        $("#chrono-hours-" + key).text(obj['time']["hours"]);
        $("#chrono-minutes-" + key).text(obj['time']["minutes"])
    }
    else{
        schedule_sources[key].close();
        delete schedule_sources[key];
        start_see(key);
        start_download_progress(obj["channel"], obj["dir"]);
    }

}

function stop_schedule_service(event){
    var key = get_key(event);
    schedule_sources[key].close();
    delete schedule_sources[key];

}

/*--------------------stop link-------------------------------------------*/

$(document).ready(function(){
    $('.stop-link').click(function(){
        var key = parseInt($(this).attr('channel'));
        $("#status-" + key).text('stop');
        stop_download_progress(key);
        show_run_result(key, "stopped", null);

    })
});

/*-------------------start link--------------------------------------------*/

$(document).ready(function(){
    $('.start-link').click(function(){
        var current_obj = $(this);
        var key = current_obj.attr('channel');
        start_see(key);
        set_bar_style("#progress-" + key, RUN_STYLES.running[1]);
        $("#progressbar-" + key).css('width', '0');
        start_download_progress(key, current_obj.attr('dir'));
    })
});

/*----------------------------- show click --------------------------------------------*/

$(document).ready(function(){
    $('.unschedule-link').click(function(){
        var current_obj = $(this);
        var key = current_obj.attr('channel');
        schedule_sources[key].close();
        delete schedule_sources[key];
        $("#unschedule-"+ key + "> a:first").hide();
        $("#unschedule-"+ key + "> label:first").show();
        $("#time-" + key).hide();
        $("#query-info-" + key).parent().show()
    })

});


/*----------------------------- unschedule click --------------------------------------------*/

$(document).ready(function(){
    $('.details-link').click(function(){
        var ref = $(this).attr('href');
        window.open(ref);
    })

});

