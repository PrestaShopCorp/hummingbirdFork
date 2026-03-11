{**
 * One Page Checkout Form - All sections
 * Rendered via {render ui=$opc_customer_address_form}, provides $formFields from OnePageCheckoutForm.
 * Contains: contact info, delivery address, billing address.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *}


{* ===== Delivery address fields ===== *}
<section class="one-page-checkout__section">
  <h2 class="one-page-checkout__title">{l s='Delivery address' d='Shop.Theme.Checkout'}</h2>

  <section class="form-fields" id="opc-address-delivery-form">
    {render ui=$opc_customer_address_form type='delivery'}
    <input type="hidden" name="saveAddress" value="delivery">
    <div class="form-check">
      <input class="form-check-input js-opc-use-same-address" type="checkbox" id="opc-use-same-address" name="use_same_address" value="1" checked>
      <label class="form-check-label" for="opc-use-same-address">
        {l s='Use this address for invoice too' d='Shop.Theme.Checkout'}
      </label>
    </div>
  </section>
</section>

{* ===== Billing address fields (hidden by default, JS manages visibility) ===== *}
<section class="one-page-checkout__section" id="opc-billing-section" style="display: none;">
  <h2 class="one-page-checkout__title">{l s='Billing address' d='Shop.Theme.Checkout'}</h2>

  <section class="form-fields" id="opc-address-invoice-form">
    {render ui=$opc_customer_address_form type='invoice'}
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
