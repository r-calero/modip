/**
 * Created with JetBrains RubyMine.
 * User: leo
 * Date: 3/10/13
 * Time: 3:58 PM
 * To change this template use File | Settings | File Templates.
 */
sources = {};
sources_assays_progress = {};
sources_compounds_progress = {};
sources_total_compounds = {};
sources_total_assays = {};

schedule_sources = {};

function start_download_service(channel, dir, assay_progress, total_assays, compound_progress, total_compounds){
    var total_assay = total_assays != 'unknown' ? parseInt(total_assays) : 100;
    var total_compound = total_compounds != 'unknown' ? parseInt(total_compounds) : 100;
    var key = parseInt(channel);
    sources_assays_progress[key] = parseInt(assay_progress);
    sources_compounds_progress[key] = parseInt(compound_progress);
    sources_total_compounds[key] = total_compound;
    sources_total_assays[key] = total_assay;
    var source = new EventSource(dir);
    sources[key] = source;

    source.addEventListener('AssayCount', assay_count, false);
    source.addEventListener('AssayProcessed', assay_process, false);
    source.addEventListener('AssayFailed', assay_process, false);
    source.addEventListener('CompoundCount', compound_count, false);
    source.addEventListener('CompoundInserted', compound_process, false);
    source.addEventListener('CompoundProcessed', compound_process, false);
    source.addEventListener('CompoundFailed', compound_process, false);
    source.addEventListener('Stop', stop, false);
    source.addEventListener('Finished', finished, false);

    $(document).ready(function(){
        var progress = sources_compounds_progress[key]/ sources_total_compounds[key];
        $("#progressbar-" + key).css('width', ( (sources_assays_progress[key] + progress)/ sources_total_assays[key]) * 100 + "%");
    }) ;

}

function start_see(key) {
    $("#status-" + key).text('running');
    $("#stop-" + key + "> label:first").hide();
    $("#stop-" + key + "> a:first").show();
    $("#start-" + key + "> label:first").show();
    $("#start-" + key + "> a:first").hide();
}

function assay_count(event){
    var obj = JSON.parse(event.data);
    var key = obj["channel"];
    sources_total_assays[key] = obj["total"];

    console.log("Total Assay = " + sources_total_assays[key]);

    sources_assays_progress[key] = 0;
    sources_compounds_progress[key] = 0;
}

function assay_process(event){
    console.log("assay processed");

    var key = get_key(event);
    sources_assays_progress[key] += 1;
    $("#progressbar-" + key).css('width', (sources_assays_progress[key]/sources_total_assays[key]) * 100 + "%");
}

function compound_count(event){
    var obj = JSON.parse(event.data);
    var key = obj["channel"];
    sources_total_compounds[key] = obj["total"];

    console.log("compound count = " + " " + obj["total"]);

    sources_compounds_progress[key] = 0;
}

function compound_process(event){
    console.log("processing compound !!!");

    var key = get_key(event);
    sources_compounds_progress[key] += 1;
    var progress = sources_compounds_progress[key]/sources_total_compounds[key];
    if(progress == 1){
        sources_assays_progress[key] += 1;
        $("#progressbar-" + key).css('width', (sources_assays_progress[key]/sources_total_assays[key]) * 100 + "%");
    }
    else{
        $("#progressbar-" + key).css('width', ((sources_assays_progress[key] + progress)/sources_total_assays[key]) * 100 + "%" );
    }

}

function finished(event){
    var key = get_key(event);
    $("#status-" + key).text('complete');
    stop_sse(key);
}

function stop(event){

    console.log("query stopped");


    var key = get_key(event);
    $("#status-" + key).text('stop');
    stop_sse(key);
}

function stop_sse(key){
    $("#start-" + key + "> label:first").hide();
    $("#stop-" + key + "> a:first").hide();
    $("#start-" + key + "> a:first").show();
    $("#stop-" + key + "> label:first").show();
    sources[key].close();
    delete sources[key];
    delete sources_assays_progress[key];
    delete sources_total_assays[key];
    delete sources_compounds_progress[key];
    delete sources_total_compounds[key];
}

function get_key(event){
    return JSON.parse(event.data)["channel"];
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
        start_download_service(obj["channel"], obj["dir"], 0, "unknown", 0, "unknown")
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
        stop_sse(key);
        $("#progressbar-" + key).css('width', '0');

    })
});

/*-------------------start link--------------------------------------------*/

$(document).ready(function(){
    $('.start-link').click(function(){
        var current_obj = $(this);
        var key = current_obj.attr('channel');
        start_see(key);
        start_download_service(current_obj.attr('channel'), current_obj.attr('dir'), 0, 'unknown', 0, 'unknown')
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

