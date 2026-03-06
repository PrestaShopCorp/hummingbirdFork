{**
 * One Page Checkout - Address fields partial
 *
 * Renders address fields from $formFields filtered by $prefix.
 * Reused for both delivery (prefix='') and billing (prefix='invoice_').
 *
 * @param array  $formFields - All form fields from OnePageCheckoutForm
 * @param string $prefix     - Field name prefix ('' or 'invoice_')
 *
 * --- Why is this template more complex than a simple foreach? ---
 *
 * PrestaShop provides form fields as a flat associative array. The field list
 * and their presence depend on country configuration and shop settings, so we
 * cannot assume any specific field will always exist.
 *
 * The design requires certain fields to be rendered side-by-side in multi-column
 * rows (firstname+lastname, city+postcode+state). Smarty has no lookahead in a
 * foreach loop, so we cannot "peek" at the next field to decide whether to open
 * a row wrapper around it.
 *
 * The solution is a two-pass approach:
 *   1. Pre-compute which grouped rows are possible (all required fields present).
 *   2. Iterate the flat array; when the first field of a group is encountered,
 *      render the whole row at once and skip the other fields of that group when
 *      they appear later in the loop.
 *
 * This is intentionally verbose — any CSS-only alternative would require all
 * fields to always be present in the DOM, which is not guaranteed here.
 *}
{foreach from=$customer.addresses item="address"}
  <div class="mb-3">
    <p>
      <strong>{$address.alias}</strong><br>
      {$address.address1} {$address.address2}<br>
      {$address.postcode} {$address.city}
    </p>

    <button
      type="button"
      class="btn btn-primary"
      data-bs-toggle="modal"
      data-bs-target="#address-modal"
      data-bs-type="edit"
      data-id_address="{$address.id}"
      data-alias="{$address.alias|escape:'html':'UTF-8'}"
      data-firstname="{$address.firstname|escape:'html':'UTF-8'}"
      data-lastname="{$address.lastname|escape:'html':'UTF-8'}"
      data-company="{$address.company|escape:'html':'UTF-8'}"
      data-vat_number="{$address.vat_number|escape:'html':'UTF-8'}"
      data-address1="{$address.address1|escape:'html':'UTF-8'}"
      data-address2="{$address.address2|escape:'html':'UTF-8'}"
      data-city="{$address.city|escape:'html':'UTF-8'}"
      data-postcode="{$address.postcode|escape:'html':'UTF-8'}"
      data-id_state="{$address.id_state}"
      data-id_country="{$address.id_country}"
      data-phone="{$address.phone|escape:'html':'UTF-8'}"
    >
      {l s='Edit address' d='Shop.Theme.Actions'}
    </button>
  </div>
  <hr>
{/foreach}

<button
  type="button"
  class="btn btn-primary"
  data-bs-toggle="modal"
  data-bs-target="#address-modal"
  data-bs-type="create"
>
  {l s='Add new address' d='Shop.Theme.Actions'}
</button>
