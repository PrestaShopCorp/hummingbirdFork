{**
 * One Page Checkout - Customer fields partial
 *
 * Renders customer fields from $formFields.
 *
 * @param array $formFields - Form fields from OnePageCheckoutForm
 *}

{hook h='displayPersonalInformationTop' customer=$customer}

{* ===== Contact information ===== *}
<section class="one-page-checkout__section" id="opc-customer-form">
  <h2 class="one-page-checkout__title">{l s='Contact information' d='Shop.Theme.Checkout'}</h2>

  <div class="one-page-checkout__links">
    <a class="one-page-checkout__link" href="{$urls.pages.authentication}?back={$urls.pages.order}">
      {l s='Already have an account? Sign in' d='Shop.Theme.Checkout'}
    </a>
    <a class="one-page-checkout__link" href="{$urls.pages.registration}">
      {l s='Create account' d='Shop.Theme.Checkout'}
    </a>
  </div>
  {foreach from=$formFields item="field"}
      {form_field field=$field}
  {/foreach}
</section>