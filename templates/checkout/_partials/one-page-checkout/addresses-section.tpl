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

<section class="one-page-checkout__section">
  <h2 class="one-page-checkout__title">{l s='Delivery address' d='Shop.Theme.Checkout'}</h2>

  <section id="opc-delivery-address" class="form-fields">
    <div id="opc-delivery-address-fields">
      {include file='checkout/_partials/one-page-checkout/address-fields.tpl'
        formFields=$deliveryFields
        prefix=''
        use_same_address=$useSameAddressField.value
      }
    </div>
    <template id="opc-delivery-address-loader">
      {include file='checkout/_partials/one-page-checkout/opc-loader.tpl'
      message={l s='Loading delivery address...' d='Shop.Theme.Checkout'}
      }
    </template>
    <input type="hidden" name="saveAddress" value="delivery">

    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="opc-use-same-address" name="use_same_address" value="1" {if $useSameAddressField.value}checked{/if}>
      <label class="form-check-label" for="opc-use-same-address">
        {l s='Use this address for invoice too' d='Shop.Theme.Checkout'}
      </label>
    </div>
  </section>
</section>

<section class="one-page-checkout__section" id="opc-billing-section" style="display: none;">
  <h2 class="one-page-checkout__title">{l s='Billing address' d='Shop.Theme.Checkout'}</h2>

  <section class="form-fields">
    <div id="opc-billing-address-fields">
    {include file='checkout/_partials/one-page-checkout/address-fields.tpl'
      formFields=$invoiceFields
      prefix='invoice_'
      use_same_address=$useSameAddressField.value
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
