$(window).on('load', function(){
$(function(){
  

  function select_AvatarType(avatar_type){
    let html = `<input value="${avatar_type}" type="hidden" name="avatar[avatar_type]" id="avatar_avatar_type">`;
    $('#avatar_avatar_type').remove();
    $('.form__type-select').append(html);
  }

  $('.form__type-select__img--1').on("click", function(e){
    console.log("1");
    e.preventDefault();
    $('.form__type-select__img--selected').removeClass('form__type-select__img--selected');
    $(this).addClass('form__type-select__img--selected');
    select_AvatarType(1);
  });

  $('.form__type-select__img--2').on("click", function(e){
    console.log("2");
    e.preventDefault();
    $('.form__type-select__img--selected').removeClass('form__type-select__img--selected');
    $(this).addClass('form__type-select__img--selected');
    select_AvatarType(2);
  });

  $('.form__type-select__img--3').on("click", function(e){
    console.log("3");
    e.preventDefault();
    $('.form__type-select__img--selected').removeClass('form__type-select__img--selected');
    $(this).addClass('form__type-select__img--selected');
    select_AvatarType(3);
  });
});
})