$(function() {
    jQuery('#slider').nivoSlider({
    	pauseTime: 25000,
    	prevText: '',
    	nextText: '',
    	directionNavHide:false, // Only show on hover
    	controlNavThumbs:false,
		afterChange: function() {
			var shown = $(this).find('.nivo-imageLink:visible');
			$('#image-details > p').html(shown.data('desc'));
			$('#image-details > a').html(shown.data('title')).attr('href', shown.attr('href'));
		}
    });
});
