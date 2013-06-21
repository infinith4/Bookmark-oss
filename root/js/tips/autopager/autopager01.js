$(function() {
    // 引き金となる要素を設定
    var triggerNode = $("#trigger");
    // 画面スクロール毎に判定を行う
    $(window).scroll(function(){
        // 引き金となる要素の位置を取得
        var triggerNodePosition = $(triggerNode).offset().top - $(window).height();
        // 現在のスクロール位置が引き金要素の位置より下にあれば‥
        if ($(window).scrollTop() > triggerNodePosition) {
            // なんらかの命令を実行
            
            $("p").append("<b>Hello</b><br>");
            console.debug("Do Something");
        }
    });
});