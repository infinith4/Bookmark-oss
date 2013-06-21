/*======================================================
初期設定
======================================================*/
//読み込むフォームのhtml
var file = "form.htm";
//フォーム全体のid名
var formContentsID = "#memoedit";
//form要素のid名
var formID = "#mailform";
//オーバーレイするレイヤーの透明度（0〜1）
var overlayOpacity = 0.5;
//オーバーレイするレイヤーの背景色
var overlayColor = "#000000";
//オーバーレイするレイヤーの背景イメージとポジション
var overlayImage = "url() repeat-x left center";
//確認画面で複数の項目を区切る文字
var separator = ", ";

//確認画面を表示中かどうかのフラグ
var isConfirm;

var memo = "aa";

strobj = document.getElementsByTagName("p").innerHTML;

var item = $("#item",$(this));
$(item).text("aadsaa");
//alert(strobj);
/*======================================================
ドキュメント読み込み後の処理
======================================================*/
$(document).ready(function(){
	//選択枠を隠す
	$('a').focus(function(e){this.blur()});
});

/*======================================================
オーバーレイフォームを開く
======================================================*/
function showform(memoid,memocontent){
	//alert(memoid + memo);
	//var editdocument = document.createElement(file);
    
	//確認画面表示中フラグをfalseに
	isConfirm = false;

	//オーバーレイ用要素を追加
	$("body").append('<div id="overlayForm"></div>');

	//背景とフォーム読み込み用要素を追加
	$("#overlayForm")
		.append('<div id="overlayBg"></div>')
		.append('<div id="formcontents"></div>');

	//オーバーレイのCSSを設定
	$("#overlayForm")
		.css("position", "fixed")
		.css("display","none")
		.css("overflow","hidden");

	//オーバーレイの配置を更新
	overlayPosition();

	//背景のCSSを設定
	$("#overlayBg")
		.css("width", "100%")
		.css("height", "100%")
		.css("background", overlayColor + " " + overlayImage)
		.css("opacity", overlayOpacity)
		.css("position", "absolute")
		.css("left", "0")
		.css("top", "0")
		.css("overflow","hidden");

	//背景クリックでフォームを閉じる
	//$("#overlayBg").click(closeform);

	//フェードインしてフォームを読み込み
	$("#overlayForm").fadeIn(500,function(){
		$("#formcontents").load("./" + file + " " + formContentsID , null, onLoaded);
	});
}

/*======================================================
フォームの読み込み完了後の処理
======================================================*/
function onLoaded(){

  	//exValidationの初期設定
	var validation = $(formID).exValidation({
		errInsertPos: 'after',
		errPosition: 'fixed',
		customClearError:  function() {
			if(!isConfirm) {
				confirm();
			}else{
 				$(formID)[0].submit();
 			}
		},
		scrollToErr:false,
	});

  	//ボタンエリアに「normal」クラスを追加し、ボタンのラベルを書き変える
	$("div.buttonArea", $(this))
		.addClass("normal")
		.find('button').html("送信内容を確認a");
	

	//読み込んだフォームのCSSを設定（画面下に配置）
	$(this).css("position", "absolute")
	.css(centerposition(this))
	.css("top", $(window).height() + $(window).scrollTop() + "px");

	//画面下からフレームインする
	$(this).animate(centerposition(this),1000,"easeOutExpo");
    
    $("#memo").text("aaa");
    
	
}

/*======================================================
センターへ配置
======================================================*/
function centerposition(obj){
	var position = new Object();
	position["left"] = ($(window).width() - $(obj).outerWidth())/2; 
	position["top"] = ($(window).height() - $(obj).outerHeight())/2;
	position["marginLeft"] = 0;
	position["marginTop"] = 0;
	return position;
}

/*======================================================
オーバーレイの配置を更新
======================================================*/
function overlayPosition(){
	$('#overlayForm')
		.css('left', "0")
		.css('top', "0")
		.css('width', $(window).width() + "px")
		.css('height', $(window).height() + "px")
	$('#test').html($(document).width());
	if($("#formcontents").length){
		$("#formcontents").css(centerposition($("#formcontents")));
	}
}

/*======================================================
スクロール、リサイズ時の処理
======================================================*/
$(window).scroll(overlayPosition);
$(window).resize(overlayPosition);

/*======================================================
入力フォーム画面から確認画面へ変更
======================================================*/
function confirm(){

	//入力フォーム画面をいったんフェードアウトして隠し、内容を更新
	$("#formcontents").css(centerposition($("#formcontents"))).animate({opacity:"0", marginLeft:"-100px"},400,"easeOutExpo",function(){

		//確認画面用タイトル追加（元のタイトルを隠す）
		$("h3", $(this)).addClass("normal");
		$("h3", $(this)).clone(true)
			.removeClass("normal")
			.addClass("confirm")
			.html("送信内容の確認")
			.insertAfter("#formcontents h3");
	
		//確認画面用のボタンを追加（元のボタンを隠す）
		$("div.buttonArea", $(this)).clone(true)
			.removeClass("normal")
			.addClass("confirm")
			.html('<button type="button" id="returnButton">内容を修正</button><button type="send" id="sendButton">この内容で送信</button>')
			.insertAfter("#formcontents div.buttonArea");
		$("#returnButton").css("background","#ccc");
		$("#returnButton").click(returnForm);
	
		//フォームの内容を確認画面用に切り替える
		$("input, textarea, select", $(formID)).each(function(i){

			//フォーム項目にすべて「nomal」クラスを付加する
			$(this).addClass("normal");

			//フォームの値を格納する変数
			var valueStr;

			//valueの型や値による処理分岐
			if(!$(this).val()) {
				//valueが偽だった場合
				var valueStr = "";
			} else if($(this).val() instanceof Array){
				//valueが配列だった場合
				var valueArray = $(this).val();
				for (i=0; i<valueArray.length; i++){
					if(valueStr){
						valueStr =  valueStr + separator + valueArray[i];
					} else {
						valueStr = valueArray[i];
					}
				}
			} else {
				//それ以外
				valueStr = $(this).val();
			}
            
			//フォームのタイプによる処理分岐
			//フォームの要素を隠してvalueをp要素として配置
			if($(this).attr("type") == "radio") {
				//ラジオボタンの場合
				var thisID = $(this).attr("id");
				$("label[for=" + thisID + "]", $(formID)).addClass("normal");
				if($(this).prop("checked")) {
					$(this).after('<p class="confirm">'+ valueStr +'</p>');
				}
			} else if($(this).attr("type") == "checkbox") {
				//チェックボックスの場合
				var thisID = $(this).attr("id");
				$("label[for=" + thisID + "]", $(formID)).addClass("normal");
				if($(this).prop("checked")) {
					$(this).after('<p class="confirm">'+ valueStr +'</p>');
				}
			} else if(this.tagName == "SELECT") {
				//選択リストの場合
				$(this).after('<p class="confirm">'+ valueStr +'</p>');
			} else if(this.tagName == "TEXTAREA") {
				//テキストエリアの場合
				valueStr = valueStr.replace(/\r\n/g, "<br />");
				valueStr = valueStr.replace(/(\n|\r)/g, "<br />");
				$(this).after('<p class="confirm">'+ valueStr +'</p>');
			} else {
				//それ以外（テキストフィールドなど）
				$(this).after('<p class="confirm">'+ valueStr +'</p>');
			}
		});

		//「nomal」クラスのオブジェクトをすべて隠す
		$(".normal", $(this)).hide();
		//「confirm」クラスのオブジェクトをすべて表示
		$(".confirm", $(this)).show();

		//値を格納した段落のCSSを設定
		$("p.confirm", $(this))
			.css("line-height","1.6")
			.css("display","inline");

		//値が複数ある場合の処理（区切り文字の追加）
		$(".field").each(function(i){
			$("p.confirm:not(:last)" ,$(this)).each(function(j){
				$(this).append(separator);
			});
		});

		//確認画面をフェードイン
		$(this).css(centerposition(this)).css("margin-left","100px").animate({opacity:"1", marginLeft: "0"},400,"easeOutExpo");
		
		//確認画面表示中フラグをtrueに
		isConfirm = true;
	});
	
}

/*======================================================
確認画面から入力フォーム画面へ戻る
======================================================*/
function returnForm(){

	//確認画面をいったんフェードアウトして隠し、内容を更新
	$("#formcontents").css(centerposition($("#formcontents"))).animate({opacity:"0", marginLeft: "100px"},400,"easeOutExpo",function(){

		//「nomal」クラスのオブジェクトをすべて表示
		$(".normal", $(this)).show();
		//「confirm」クラスのオブジェクトをすべて削除
		$(".confirm", $(this)).remove();

		//入力フォーム画面をフェードイン
		$(this).css(centerposition(this)).css("margin-left","-100px").animate({opacity:"1", marginLeft: "0"},400,"easeOutExpo");

		//確認画面表示中フラグをfalseに
		isConfirm = false;
	});
}


/*======================================================
閉じる
======================================================*/
function closeform(){
	$("#overlayForm").fadeOut(250,function(){$(this).remove()});

}
