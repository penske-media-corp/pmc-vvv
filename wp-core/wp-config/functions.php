<?php
/*
 * helper functions
 */

if ( ! function_exists('ifndef') ) {
	function ifndef( $key, $value ) {
		if ( ! defined( $key ) ) {
			define( $key, $value );
		}
	}
}

if ( ! function_exists('ifdefenv') ) {
	function ifdefenv( $key, $default = null, $name = null ) {
		if ( empty( $name ) ) {
			$name = $key;
		}
		$value = getenv( $name );
		if ( ! empty( $value ) ) {
			ifndef( $key, $value );
		}
		elseif ( isset( $_SERVER[ $name ] ) ) {
			ifndef( $key , $_SERVER[ $name ] );
		}
		elseif ( null !== $default ) {
			ifndef( $key, $default );
		}
	}
}
