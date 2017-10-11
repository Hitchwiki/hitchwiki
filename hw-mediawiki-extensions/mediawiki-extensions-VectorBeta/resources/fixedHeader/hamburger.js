jQuery( function( $ ) {
	function exitNav() {
		$( 'body' ).removeClass( 'mw-navigation-enabled' );
	}

	$( '#mw-main-menu-button' ).on( 'click', function() {
		$( 'body' ).toggleClass( 'mw-navigation-enabled' );
		$( window ).one( 'resize', exitNav );
		return false;
	} );
} );
