{**
 * One Page Checkout Form - All sections
 * Rendered via {render ui=$opc_form}, provides $formFields from OnePageCheckoutForm.
 * Contains: contact info, delivery address, billing address.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *}

{hook h='displayPersonalInformationTop' customer=$customer}

{include file='_partials/form-errors.tpl' errors=$errors['']}
{* Delivery Address Modal *}
{include file='checkout/_partials/one-page-checkout/address-modal.tpl'
modal_id='modal-delivery'
formFields=$deliveryFields
title_new={l s='New delivery address' d='Shop.Theme.Checkout'}
title_edit={l s='Edit delivery address' d='Shop.Theme.Checkout'}
address_type='delivery'
prefix=''
}

{* Billing Address Modal *}
{include file='checkout/_partials/one-page-checkout/address-modal.tpl'
modal_id='modal-invoice'
formFields=$invoiceFields
title_new={l s='New billing address' d='Shop.Theme.Checkout'}
title_edit={l s='Edit billing address' d='Shop.Theme.Checkout'}
address_type='invoice'
prefix='invoice_'
}

{* ===== Contact information ===== *}
{if !$customer.is_logged}
  <section class="one-page-checkout__section">
    <h2 class="one-page-checkout__title">{l s='Contact information' d='Shop.Theme.Checkout'}</h2>

    <div class="one-page-checkout__links">
      <a class="one-page-checkout__link" href="{$urls.pages.authentication}?back={$urls.pages.order}">
        {l s='Already have an account? Sign in' d='Shop.Theme.Checkout'}
      </a>
      <a class="one-page-checkout__link" href="{$urls.pages.registration}?back={$urls.pages.order}">
        {l s='Create account' d='Shop.Theme.Checkout'}
      </a>
    </div>

    {if isset($contactFields['email'])}
      <div class="one-page-checkout__field">
        <label class="form-label" for="field-email">{l s='Continue as guest' d='Shop.Theme.Checkout'}</label>
        <input class="form-control" type="email" name="email" id="field-email" value="{$contactFields['email']['value']}" required>
      </div>
    {/if}

    {if isset($contactFields['optin'])}
      <div class="one-page-checkout__field">
        {form_field field=$contactFields['optin']}
      </div>
    {/if}

    {foreach from=$additionalCustomerFields item="field"}
      <div class="one-page-checkout__field">
        {form_field field=$field}
      </div>
    {/foreach}

  </section>
{else}
  <section class="one-page-checkout__section">
    <h2 class="one-page-checkout__title">{l s='Contact information' d='Shop.Theme.Checkout'}</h2>
    {include file='checkout/_partials/connected-account-info.tpl'}
  </section>
{/if}
{* ===== Delivery address fields ===== *}
<section class="one-page-checkout__section">
  <h2 class="one-page-checkout__title">{l s='Delivery address' d='Shop.Theme.Checkout'}</h2>

  <section id="opc-delivery-address" class="form-fields">
    <div id="opc-delivery-address-fields">
      {include file='checkout/_partials/one-page-checkout/address-fields.tpl'
        formFields=$deliveryFields
        prefix=''
        selected_address=$cart.id_address_delivery
      }
    </div>
    <template id="opc-delivery-address-loader">
      {include file='checkout/_partials/one-page-checkout/opc-loader.tpl'
      message={l s='Loading delivery address...' d='Shop.Theme.Checkout'}
      }
    </template>
    <input type="hidden" name="saveAddress" value="delivery">

    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="opc-use-same-address" name="use_same_address" value="1" checked>
      <label class="form-check-label" for="opc-use-same-address">
        {l s='Use this address for invoice too' d='Shop.Theme.Checkout'}
      </label>
    </div>
  </section>
</section>

{* ===== Billing address fields (hidden by default, JS manages visibility) ===== *}
<section class="one-page-checkout__section" id="opc-billing-section" style="display: none;">
  <h2 class="one-page-checkout__title">{l s='Billing address' d='Shop.Theme.Checkout'}</h2>

  <section class="form-fields">
    <div id="opc-billing-address-fields">
    {include file='checkout/_partials/one-page-checkout/address-fields.tpl'
      formFields=$invoiceFields
      prefix='invoice_'
      selected_address=$cart.id_address_invoice
    }
    </div>
    <template id="opc-billing-address-loader">
      {include file='checkout/_partials/one-page-checkout/opc-loader.tpl'
      message={l s='Loading billing address...' d='Shop.Theme.Checkout'}
      }
    </template>
  </section>
</section>

{capture name="address_selector_bottom"}{hook h='displayAddressSelectorBottom'}{/capture}
{if $smarty.capture.address_selector_bottom}
  {block name='address_selector_bottom'}
    <div class="address-selector-bottom mt-3">
      {$smarty.capture.address_selector_bottom nofilter}
    </div>
  {/block}
{/if}
