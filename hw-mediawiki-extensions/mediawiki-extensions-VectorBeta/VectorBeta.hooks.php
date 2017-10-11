<?php
/*
 * This file is part of the MediaWiki extension VectorBeta.
 *
 * VectorBeta is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * VectorBeta is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with VectorBeta.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @file
 * @ingroup extensions
 */

class VectorBetaHooks {
	/**
	 * Constructs the HTML for a menu based on definitions found
	 * in $menuItems.
	 *
	 * @param array $menuItems where each item is an array with keys for id and text
	 * @return string HTML markup representing a menu
	 */
	static function getHtmlMenuHtml( $menuItems ) {
		$htmlMenu = '';
		foreach( $menuItems as $key => $item ) {
			$className = isset( $item['class'] ) ? $item['class']. ' ' : '';
			$className .= 'mw-menu-item mw-icon mw-' . $key . '-icon';
			if ( strpos( $item['id'], 'ca-nstab' ) === 0 ) {
				$className .= ' mw-page-icon';
			} elseif ( $item['id'] == 'ca-talk' ) {
				$className .= ' mw-talk-icon';
			}
			$htmlMenu .= Html::openElement( 'li', array(
				'id' => $item['id'],
				'class' => $className,
			) ) .
			Html::element( 'a', array(
				'href' => $item['href'],
				// Needed for purpose of watchlist
				'title' => isset( $item['title'] ) ? $item['title'] : $item['text'],
				'class' => 'mw-ui-button mw-ui-quiet',
			), $item['text'] ) .
			Html::closeElement( 'li' );
		}
		return $htmlMenu;
	}

	/**
	 * RequestContextCreateSkin hook handler
	 * @see https://www.mediawiki.org/wiki/Manual:Hooks/RequestContextCreateSkin
	 *
	 * @param IContextSource $ctx
	 * @param Skin $skin
	 * @return bool
	 */
	public static function onRequestContextCreateSkin( $ctx, $skin ) {
		self::enableMediaWikiUIEverywhere( $ctx->getUser() );
		return true;
	}

	/**
	 * MediaWikiPerformAction hook handler
	 * @see https://www.mediawiki.org/wiki/Manual:Hooks/MediaWikiPerformAction
	 *
	 * @param $output
	 * @param $article
	 * @param $title
	 * @param $user
	 * @param $request
	 * @param $wiki
	 * @return bool
	 */
	public static function onMediaWikiPerformAction( $output, $article, $title, $user, $request, $wiki ) {
		self::enableMediaWikiUIEverywhere( $user );
		return true;
	}


	/**
	 * Set $wgUseMediaWikiUIEverywhere to true is the user
	 * has the form refresh beta feature enabled.
	 *
	 * @param $user
	 * @return bool
	 */
	static function enableMediaWikiUIEverywhere( $user ) {
		global $wgUseMediaWikiUIEverywhere;

		if ( self::isFormRefreshEnabled( $user ) ) {
			// Turn on MediaWiki UI styles so special pages with forms are styled.
			// FIXME: Remove when this becomes default.
			$wgUseMediaWikiUIEverywhere = true;
		}

		return true;
	}

	/**
	 * Checks whether form refresh experiment can be run or not
	 * @param User $user
	 * @return bool
	 */
	static function isFormRefreshEnabled( $user ) {
		global $wgVectorBetaFormRefresh;
		return $wgVectorBetaFormRefresh &&
			BetaFeatures::isFeatureEnabled( $user, 'betafeatures-vector-form-refresh' );
	}

	/**
	 * Checks whether fixed header experiment can be run or not
	 * @param User $user
	 * @return bool
	 */
	static function isFixedHeaderEnabled( $user ) {
		global $wgVectorBetaWinter;
		return $wgVectorBetaWinter &&
			BetaFeatures::isFeatureEnabled( $user, 'betafeatures-vector-fixedheader' );
	}

	/**
	 * GetSkinTemplateOutputPageBeforeExec
	 * Modifies the template to swap out the default navigation controls with new Winter
	 * ones.
	 * @see https://www.mediawiki.org/wiki/Manual:Hooks/SkinTemplateOutputPageBeforeExec
	 *
	 * @param Skin $skin
	 * @param SkinTemplate $tpl
	 * @return bool
	 */
	static function getSkinTemplateOutputPageBeforeExec( $skin, $tpl ) {
		// Ensure these beta features don't run against another skin!
		// FIXME: See bug 62897
		if ( $skin->getSkinName() !== 'vector' ) {
			return true;
		}
		if ( !class_exists( 'BetaFeatures' ) ) {
			wfDebugLog( 'VectorBeta', 'The BetaFeatures extension is not installed' );
			return true;
		} elseif ( self::isFixedHeaderEnabled( $skin->getUser() ) ) {
			$data = $tpl->data;
			$skin = $data['skin'];
			$nav = $data['content_navigation'];

			$pageActions = self::constructPageActionsMainMenu( $tpl );
			$morePageActions = self::constructPageActionsMoreMenu( $tpl, $skin->getTitle() );

			$prebodytext = $tpl->data['prebodyhtml'] .
				self::getPageActionsHtml( $pageActions, $morePageActions ) .
				self::getEditButtonHtml( $tpl );
			$nav['namespaces'] = array();
			$nav['views'] = array(
				'menu' => array(
					'class' => '',
					'text' => wfMessage( 'navigation-heading' ),
					'href' => SpecialPage::getTitleFor( 'MobileMenu' )->getLocalUrl(),
					'id' => 'mw-main-menu-button',
				),
			);
			$nav['actions'] = array();
			$tpl->set( 'prebodyhtml', $prebodytext );
			$tpl->set( 'content_navigation', $nav );
		}
		return true;
	}

	/**
	 * Constructs a new page actions menu based on values found in SkinTemplate
	 * Note if ever upstreamed the construction of this menu should be done more elegantly
	 *
	 * @param SkinTemplate $tpl
	 * @return array A menu representing the new main menu derived from items found in the old menus
	 */
	static function constructPageActionsMainMenu( $tpl ) {
		$nav = $tpl->data['content_navigation'];
		$views = $nav['views'];
		$ns = $nav['namespaces'];
		$actions = $nav['actions'];
		// Construct a page actions menu that will appear under the heading.
		$pageActions = array();

		// The view link appears in both views and namespace. Unset it in views so it only appears once.
		unset( $views['view'] );
		// There is a chance of multiple items being selected in the different menus
		// Since we are merging them into one big menu we need to remove the selected
		// class from several menu items.
		$otherSelected = false;
		foreach( array_merge( $actions, $views ) as $item ) {
			if ( strpos( $item['class'], 'selected' ) !== false ) {
				$otherSelected = true;
			}
		}
		foreach( $ns as $key => $item ) {
			if ( $otherSelected ) {
				$item['class'] = str_replace( 'selected', '', $item['class'] );
			}
			$pageActions[$key] = $item;
		}

		// Add the history link if available
		if ( isset( $views['history'] ) ) {
			$pageActions['history'] = $views['history'];
		}

		// Add watch star if available
		if ( isset( $actions['watch'] ) ) {
			$pageActions['watch'] = $actions['watch'];
			// Make ajax work
			$pageActions['watch']['class'] .= ' mw-watchlink';
			unset( $actions['watch'] );
		} elseif ( isset( $actions['unwatch'] ) ){
			$pageActions['unwatch'] = $actions['unwatch'];
			// Make ajax work
			$pageActions['unwatch']['class'] .= ' mw-watchlink';
			unset( $actions['unwatch'] );
		}

		return $pageActions;
	}

	/**
	 * Constructs a menu of secondary page actions menu based on values found in SkinTemplate
	 * Note if ever upstreamed the construction of this menu should be done more elegantly
	 *
	 * @param SkinTemplate $tpl
	 * @param Title $title title of current page
	 * @return array A menu representing the new main menu derived from items found in the old menus
	 */
	static function constructPageActionsMoreMenu( $tpl, $title ) {
		$actions = $tpl->data['content_navigation']['actions'];

		// Construct the more menu
		$actions['links'] = array(
			'text' => wfMessage( 'whatlinkshere' ),
			'class' => '',
			'id' => 'ca-links',
			'href' => SpecialPage::getTitleFor( 'Whatlinkshere', $title->getPrefixedText() )->getLocalUrl(),
		);
		$actions['print'] = array(
			'text' => wfMessage( 'printableversion' ),
			'id' => 'ca-print',
			'href' => $title->getLocalUrl( array( 'printable' => 'yes' ) ),
		);
		return $actions;
	}

	/**
	 * Generates HTML representation of the page actions menu, where secondary actions
	 * are hidden inside a more menu.
	 *
	 * @param array $mainActions primary actions that can be carried out on the page
	 * @param array $moreActions secondary actions that can be carried out on the page
	 * @return string HTML representation of the menu
	 */
	static function getPageActionsHtml( $mainActions, $moreActions ) {
		return Html::openElement( 'ul', array( 'id' => 'mw-page-actions', 'class' => 'mw-menu' ) ) .
			self::getHtmlMenuHtml( $mainActions ) .
			Html::openElement( 'li', array( 'class' => 'mw-icon mw-more-icon mw-menu-item' ) ) .
			Html::openElement( 'ul', array( 'class' => 'mw-more-menu' ) ) .
			self::getHtmlMenuHtml( $moreActions ) .
			Html::closeElement( 'ul' ) .
			Html::closeElement( 'li' ) .
			Html::closeElement( 'ul' );
	}

	/**
	 * Generates HTML representation of the page actions menu, where secondary actions
	 * are hidden inside a more menu.
	 *
	 * @param SkinTemplate $tpl
	 * @return string HTML representation of the edit button
	 */
	static function getEditButtonHtml( $tpl ) {
		$views = $tpl->data['content_navigation']['views'];
		// Unset the history link and the view link
		unset( $views['history'] );
		unset( $views['view'] );

		// Figures out what to show as primary edit button
		// Rest of the edit options are going to be hidden behing "..." button
		if ( isset( $views['ve-edit'] ) ) {
			// "Edit" using Visual Editor is the primary option
			$edit = $views['ve-edit'];
		} else if ( isset( $views['formedit'] ) ) {
			// "Edit with form" is the primary option
			$edit = $views['formedit'];
		} else if ( isset( $views['edit'] ) ) {
			// "Edit source" is the primary option
			$edit = $views['edit'];
		} elseif ( isset( $views['viewsource'] ) ) {
			$edit = $views['viewsource'];
		} else {
			$edit = false;
		}
		if ( $edit ) {
			return Html::openElement( 'div',
					array(
						'class' => 'mw-main-edit-button mw-ui-progressive mw-ui-button',
					)
				) . Html::element( 'a',
					array(
					'href' => $edit['href'],
					'class' => 'mw-icon mw-edit-icon',
				), $edit['text'] ) .
				Html::openElement( 'div', array( 'class' => 'mw-icon mw-more-icon mw-menu-item' ) ) .
				Html::openElement( 'ul', array( 'class' => 'mw-more-menu' ) ) .
				self::getHtmlMenuHtml( $views ) .
				Html::closeElement( 'ul' ) .
				Html::closeElement( 'div' ) . // close more menu
				Html::closeElement( 'div' ); // close edit button
		} else {
			return '';
		}
	}

	static function getPreferences( $user, &$prefs ) {
		global $wgExtensionAssetsPath, $wgVectorBetaPersonalBar,
			$wgVectorBetaTypography, $wgVectorBetaWinter, $wgVectorBetaFormRefresh;

		if ( $wgVectorBetaTypography ) {
			$prefs['betafeatures-vector-typography-update'] = array(
				'label-message' => 'vector-beta-feature-typography-message',
				'desc-message' => 'vector-beta-feature-typography-description',
				'info-link' => 'https://www.mediawiki.org/wiki/Typography_refresh',
				'discussion-link' => 'https://www.mediawiki.org/wiki/Talk:Typography_refresh',
				'screenshot' => array(
					'ltr' => $wgExtensionAssetsPath . '/VectorBeta/typography-beta.svg',
					'rtl' => $wgExtensionAssetsPath . '/VectorBeta/typography-beta-arab.svg',
					'he' => $wgExtensionAssetsPath . '/VectorBeta/typography-beta-hebr.svg',
					'yi' => $wgExtensionAssetsPath . '/VectorBeta/typography-beta-hebr.svg',
				),
				'requirements' => array(
					'skins' => array( 'vector' ),
				),
			);
		}

		if ( $wgVectorBetaFormRefresh ) {
			$prefs['betafeatures-vector-form-refresh'] = array(
				'label-message' => 'vector-beta-feature-form-refresh-message',
				'desc-message' => 'vector-beta-feature-form-refresh-description',
				'info-link' => 'https://www.mediawiki.org/wiki/MediaWiki_UI',
				'discussion-link' => 'https://www.mediawiki.org/wiki/Talk:MediaWiki_UI',
				'screenshot' => array (
					'ltr' => $wgExtensionAssetsPath . '/VectorBeta/form-refresh-beta.svg',
					'rtl' => $wgExtensionAssetsPath . '/VectorBeta/form-refresh-beta-rtl.svg',
				),
				'requirements' => array(
					'skins' => array( 'vector' ),
				),
			);
		}

		if ( $wgVectorBetaPersonalBar ) {
			$prefs['betafeatures-vector-compact-personal-bar'] = array(
				'label-message' => 'vector-beta-feature-compact-personal-bar-message',
				'desc-message' => 'vector-beta-feature-compact-personal-bar-description',
				'info-link' => 'https://www.mediawiki.org/wiki/Compact_Personal_Bar',
				'discussion-link' => 'https://www.mediawiki.org/wiki/Talk:Compact_Personal_Bar',
				'screenshot' => array(
					'ltr' => "$wgExtensionAssetsPath/VectorBeta/compactPersonalBar-ltr.svg",
					'rtl' => "$wgExtensionAssetsPath/VectorBeta/compactPersonalBar-rtl.svg",
				),
				'requirements' => array(
					'skins' => array( 'vector' ),
					'javascript' => true,
					'blacklist' => array(
						'msie' => null,
					),
				),
			);
		}

		if ( $wgVectorBetaWinter ) {
			$prefs['betafeatures-vector-fixedheader'] = array(
				'label-message' => 'vector-beta-feature-fixedheader-message',
				'desc-message' => 'vector-beta-feature-fixedheader-description',
				'info-link' => '//www.mediawiki.org/wiki/Fixed header',
				'discussion-link' => '//www.mediawiki.org/wiki/Talk:Fixed header',
				// FIXME: Get a screenshot from Jared asap
				'screenshot' => '',
				'requirements' => array(
					'skins' => array( 'vector' ),
				),
			);
		}

		return true;
	}

	/**
	 * Handler for SkinVectorStyleModules
	 * @param Skin $skin
	 * @param array $modules
	 * @return bool
	 */
	static function skinVectorStyleModules( $skin, &$modules ) {
		global $wgVectorBetaTypography;

		if ( class_exists( 'BetaFeatures' ) ) {
			$typeEnabled = $wgVectorBetaTypography &&
				BetaFeatures::isFeatureEnabled( $skin->getUser(), 'betafeatures-vector-typography-update' );

			if ( $typeEnabled ) {
				$modules[] = 'skins.vector.beta';
			}
			if ( self::isFixedHeaderEnabled( $skin->getUser() ) ) {
				$modules[] = 'skins.vector.header.beta';
			}
		} else {
			wfDebugLog( 'VectorBeta', 'The BetaFeatures extension is not installed' );
		}

		return true;
	}

	/**
	 * Handler for BeforePageDisplay
	 * @param OutputPage $out
	 * @param Skin $skin
	 * @return bool
	 */
	static function onBeforePageDisplay( &$out, &$skin ) {
		// Ensure these beta features don't run against another skin!
		// FIXME: See bug 62897
		if ( $skin->getSkinName() !== 'vector' ) {
			return true;
		}
		if ( class_exists( 'BetaFeatures' ) ) {
			$user = $out->getUser();
			$modules = array();

			// Fixed header experiment modules
			if ( self::isFixedHeaderEnabled( $user ) ) {
				$modules[] = 'skins.vector.headerjs.beta';
			}

			// Compact Personal Bar modules
			if ( BetaFeatures::isFeatureEnabled( $user, 'betafeatures-vector-compact-personal-bar' ) ) {
				$modules[] = 'skins.vector.compactPersonalBar';
			}

			$out->addModules( $modules );
		} else {
			wfDebugLog( 'VectorBeta', 'The BetaFeatures extension is not installed' );
		}

		return true;
	}

}
