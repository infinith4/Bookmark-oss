var search_msg_data;
$("#search_data").html('Now Loading...');
$.ajax({
    type: "GET",
    url: "hoge.pl",
    success: function(msg){
        search_msg_data = msg;
        setTimeout('search_json()', 1000); // タイムラグ表示(Now Loading確認用)
//search_json(); // すぐに表示
    }
});

function search_json(){
    var get_json = eval("("+search_msg_data+")");
    if(get_json.results == null){
        $("#search_data").html("該当するデータは見つかりませんでした。")
    }
    else{
        var hash = get_json["results"];
        var search_html = "";
        for(var i in hash){
            search_html += '<dt>' + hash[i].name + '</dt>';
            search_html += '<dd>' + hash[i].address + '</dd>';
        }
        $("#search_data").html('<dl>' + search_html + '</dl>');
    }
}