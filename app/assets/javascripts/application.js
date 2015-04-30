// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require bootstrap-sprockets

jQuery(document).ready(function() {

	var bla = {}
	$('.answers').hide(); //Hide/close all containers
    $('.additional').hide();
	$('.icon').click(function(){
	
		$('#q' + $(this).attr('id')).find('.answers').toggle();
		//$('#q' + $(this).attr('id')).toggleClass(.text,:)
		//if($(this).find('.answers'))
		$('#q' + $(this).attr('id')).find('.additional').toggle();
		//$('#q' + $(this).attr('id')).find('.text').css("height","auto");
		$('#q' + $(this).attr('id')).find('.text, .toggler').toggleClass("text toggler");
		

		//$('#question-0').find('.text').attr("color","red");
	});
});

