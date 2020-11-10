<?php
namespace WP\Config;

if ( ! defined( 'IS_UNIT_TEST' ) ) {
	define( 'IS_UNIT_TEST', true );
}

require_once realpath ( __DIR__ . '/bootstrap.php' );

/**
 * This bootsrap tests file is responsible for detecting project environment and various settings
 */

class Bootstrap_Phpunit extends Bootstrap {

	protected static $_instance = null;
	private $_bootstrap         = false;

	protected function __construct() {

		ifndef( 'WP_BATCACHE', false );

		if ( preg_match( '@/www/([^/]+)/@', getcwd(), $matches ) ) {
			switch( $matches[1] ) {
				case 'vipgo':
					ifndef( 'IS_VIP_GO', true );
					break;
				case 'wpcom':
					ifndef( 'IS_VIP_GO', false );
					break;
			}
		}

		if ( preg_match( '#^.*/pmc-plugins/#', getcwd(), $matches ) ) {
			ifndef( 'IS_VIP_GO', false );
			ifndef( 'SITE_NAME', 'pmc-plugins' );
			$this->_bootstrap = $matches[0] . 'pmc-unit-test/bootstrap.php';
		}

		parent::__construct();

		$theme_folder = dirname( $this->site_info->folder );
		if ( empty( $this->_bootstrap ) ) {
			if ( file_exists( $theme_folder . '/pmc-plugins/pmc-unit-test/bootstrap.php' ) ) {
				$this->_bootstrap = $theme_folder . '/pmc-plugins/pmc-unit-test/bootstrap.php';
			} else {
				if ( preg_match( '#^.*/wp-content#', $this->site_info->folder, $matches ) ) {
					if ( file_exists( $matches[0] . '/plugins/pmc-plugins/pmc-unit-test/bootstrap.php' ) ) {
						$this->_bootstrap = $matches[0] . '/plugins/pmc-plugins/pmc-unit-test/bootstrap.php';
					}
				}
				if ( empty( $this->_bootstrap ) ) {
					if ( file_exists( '/srv/www/pmc/coretech/pmc-plugins/pmc-unit-test/bootstrap.php' ) ) {
						$this->_bootstrap = '/srv/www/pmc/coretech/pmc-plugins/pmc-unit-test/bootstrap.php';
					}
				}
			}
		}

		if  ( ! empty( $this->site_info->wp_tests_folder ) ) {
			$phpunit_dir = $this->site_info->wp_tests_folder;
		}

		if ( empty( $phpunit_dir ) || ! file_exists( $phpunit_dir ) ) {

			$phpunit_dir = false;
			if ( preg_match( '#(.*)/[^/]+/wp-content/#', $theme_folder, $matches ) ) {
				if ( file_exists( $matches[1] . '/wp-tests/phpunit' ) ) {
					$phpunit_dir = $matches[1] . '/wp-tests/phpunit';
				}
			}
			$check_dir   = $theme_folder;
			$check_level = 10;
			while ( $check_level > 0 && !$phpunit_dir && !empty( $check_dir ) && ! in_array( $check_dir, [ '.', '/' ], true ) ) {
				$check_level -= 1;
				$check_dir = dirname( $check_dir );
				if ( in_array( $check_dir, [ '.', '/' ], true ) ) {
					break;
				}
				if ( file_exists( $check_dir . '/wp-tests/phpunit' ) ) {
					$phpunit_dir = $check_dir . '/wp-tests/phpunit';
				}
			}


		}

		if ( empty( $phpunit_dir ) || ! file_exists( $phpunit_dir ) ) {
			$phpunit_dir = getenv( 'WP_TESTS_DIR' );
		}

		if ( empty( $phpunit_dir ) || ! file_exists( $phpunit_dir ) ) {
			throw new \Error( 'Cannot auto detect location for wp-tests folder' );
		}
		putenv( 'WP_TESTS_DIR=' . $phpunit_dir );

		if ( file_exists( $phpunit_dir . '/wp-tests-config.php' ) ) {
			ifndef( 'WP_TESTS_CONFIG_FILE_PATH', realpath( $phpunit_dir . '/wp-tests-config.php' ) );
		}
		elseif ( file_exists( $phpunit_dir . '/../wp-tests-config.php' ) ) {
			ifndef( 'WP_TESTS_CONFIG_FILE_PATH', realpath( $phpunit_dir . '/../wp-tests-config.php' ) );
		}

	}

	/**
	 * phpunit test should always active once it is manually referenced
	 */
	public function is_active() {
		return true;
	}

	public function start() {
		if ( empty( $this->_bootstrap ) ) {
			throw new \Error( sprintf('Cannot auto detect pmc plugin bootstrap file location' ) );
		}
		if ( ! file_exists( $this->_bootstrap ) ) {
			throw new \Error( sprintf('Cannot locate bootstrap file: %s', $this->_bootstrap ) );
		}
		require_once $this->_bootstrap;
	}
}

Bootstrap_Phpunit::get_instance()->start();
