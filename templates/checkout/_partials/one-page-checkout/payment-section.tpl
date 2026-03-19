{**
 * OPC — Payment method section
 * Included by one-page-checkout.tpl.
 * Also renderable standalone for AJAX refresh.
 *
 * Variables:
 *   $payment_options          - available payment options (may be empty on first load)
 *   $is_free                  - boolean, true when cart total is 0
 *   $selected_payment_module  - module_name of the currently selected payment option (stable across renders)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *}

<section class="one-page-checkout__section js-opc-payment-section">
  <h2 class="one-page-checkout__title">{l s='Payment method' d='Shop.Theme.Checkout'}</h2>

  {hook h='displayPaymentTop'}

  <div class="one-page-checkout__placeholder" id="opc-payment-methods"
    data-url-update="{url entity='order' params=['ajax' => 1, 'action' => 'opcSelectPayment']}"
  >
    {if $payment_options|count}
      {include file='checkout/_partials/one-page-checkout/payment-methods.tpl'
        payment_options=$payment_options
        is_free=$is_free
        selected_payment_module=$selected_payment_module
      }
    {else}
      <div class="card card-body bg-light">
        {l s='You will see the available payment methods once you\'ve entered your delivery address.' d='Shop.Theme.Checkout'}
      </div>
    {/if}
  </div>

  <template id="opc-template-payment-loader">
    {include file='checkout/_partials/one-page-checkout/opc-loader.tpl'
      message={l s='Loading payment methods...' d='Shop.Theme.Checkout'}
    }
  </template>

  <template id="opc-template-payment-error">
    {include file='checkout/_partials/one-page-checkout/opc-error.tpl'
      message={l s='An error occurred while loading payment methods. Please try again.' d='Shop.Theme.Checkout'}
      retry_label={l s='Retry' d='Shop.Theme.Checkout'}
      retry_action='retry-payment'
    }
  </template>
</section>
