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
        $("#progressbar-" + key).css("width", p.percent + "%");
        if (p.running) {
            $("#status-" + key).text("running");
            if (p.total_assays) {
                $("#query-info-" + key).text(p.completed_assays + " of " + p.total_assays + " assays (" + p.percent + "%)");
            }
        } else if (p.status === "idle" && poll.idle < 3) {
            poll.idle += 1; // the download may not have started yet
        } else {
            $("#status-" + key).text(p.status === "idle" ? "stop" : p.status);
            if (p.status === "complete") { $("#query-info-" + key).text("download complete"); }
            stop_download_progress(key);
            return;
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

function stop_download_progress(key){
    $("#start-" + key + "> label:first").hide();
    $("#stop-" + key + "> a:first").hide();
    $("#start-" + key + "> a:first").show();
    $("#stop-" + key + "> label:first").show();
    delete download_polls[key];
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
        $("#progressbar-" + key).css('width', '0');

    })
});

/*-------------------start link--------------------------------------------*/

$(document).ready(function(){
    $('.start-link').click(function(){
        var current_obj = $(this);
        var key = current_obj.attr('channel');
        start_see(key);
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

