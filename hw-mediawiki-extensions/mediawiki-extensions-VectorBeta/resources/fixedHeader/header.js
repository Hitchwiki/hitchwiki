jQuery( function( $ ) {
	var $body = $( 'body' ), threshold = $( '#p-logo' ).height() - 10;
	function goPositionFixed() {
		if ( $( this ).scrollTop() > threshold && !$body.hasClass( 'mw-special-MobileMenu' ) ) {
			$body.addClass( 'mw-scrolled' );
		} else {
			$body.removeClass( 'mw-scrolled' );
		}
	}
	$( window ).on( 'scroll', $.debounce( 0, goPositionFixed ) );
} );
