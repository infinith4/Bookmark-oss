$(function(){
     // id="jQuerySample2" を親要素に持つdivを非表示
    $("#alltagopen > div").css("display", "none");
  
     // id="jQuerySample2"を親要素に持つi番目のh5が
     // クリックされた時、i番目のdivの表示、非表示切り替え
    $("#alltagopen > h5").each(function(i){
        $(this).click(function(){
            $("#alltagopen > div").eq(i).toggle();
        });
    });
});