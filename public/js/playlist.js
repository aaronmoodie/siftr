var audio = $('audio')

audio.bind('play',function() {

  $('#play-player').hide().siblings().show();

}).bind('pause', function() {

  $('#pause-player').hide().siblings().show();

}).bind('ended', function() {

  $('li.playing').next().find('.mp3').click();

});

$('#play-player, #pause-player').click(function(e) {
  e.preventDefault();

  if(!$('source', audio[0]).attr('src').length) {
    $('#container li').first().find('.mp3').click();
    return;
  }

  if (!audio[0].paused) { audio[0].pause(); }
  else { audio[0].play(); }

  $(this).hide().siblings().show();

})

$('li .mp3').click(function(e) {
  e.preventDefault();

  $(this).parent().addClass('playing').siblings().removeClass('playing');

  $('source', audio[0]).attr('src', $(this).attr('href'));
  audio[0].load();
  audio[0].play();
})

$(document).keydown(function(e) {
  var unicode = e.charCode ? e.charCode : e.keyCode;
     // right arrow
  if (unicode == 39) {
    $('li.playing').next().find('.mp3').click();
    // back arrow
  } else if (unicode == 37) {
    $('li.playing').prev().find('.mp3').click();
    // 'f'
  } else if (unicode == 70) {
    $('li.playing').find('a').last().click();
  }
})

$('#container li a:last-child').click(function(e) {

  e.preventDefault();

  var url = (this.className == 'favourite' ? '/favourite/' : '/unfavourite/' ),
      that = this;

  $.ajax({
    url: url + this.id,
    error: function(request, status, error) {
      alert(status+': '+error);
    },
    success: function() {
      that.className = (that.className == 'favourite') ? 'unfavourite' : 'favourite';
    }
  });
});


// skip to end of track
// $(audio)[0].currentTime = $(audio)[0].duration - 2