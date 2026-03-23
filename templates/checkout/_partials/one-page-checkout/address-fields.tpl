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

{* ===== Prefix length for stripping ===== *}
{assign var="_prefix_len" value=$prefix|strlen}
{* ===== Build prefixed key names ===== *}
{assign var="_key_firstname" value="{$prefix}firstname"}
{assign var="_key_lastname" value="{$prefix}lastname"}
{assign var="_key_city" value="{$prefix}city"}
{assign var="_key_postcode" value="{$prefix}postcode"}
{assign var="_key_id_state" value="{$prefix}id_state"}

{*
  Pass 1 — pre-compute which grouped rows are available.
  A row is only rendered if ALL its required fields exist; otherwise each field
  falls back to the default single-column rendering.
*}
{assign var="_has_name_row" value=isset($formFields[$_key_firstname]) && isset($formFields[$_key_lastname])}
{assign var="_has_city_row" value=isset($formFields[$_key_city]) && isset($formFields[$_key_postcode])}
{assign var="_has_state" value=isset($formFields[$_key_id_state])}

{* Pass 2 — render each field, grouping into multi-column rows where applicable *}
{foreach from=$formFields item="field"}
  {* Only render fields matching our prefix *}
  {if $prefix && strpos($field.name, $prefix) !== 0}{continue}{/if}
  {if !$prefix && strpos($field.name, 'invoice_') === 0}{continue}{/if}

  {* Strip prefix to get the base field name used in comparisons below *}
  {if $prefix}
    {assign var="_base" value=$field.name|substr:$_prefix_len}
  {else}
    {assign var="_base" value=$field.name}
  {/if}

  {* ----- alias: always present but never displayed — emit as hidden input ----- *}
  {if $_base === 'alias'}
    <input type="hidden" name="{$field.name}" value="My address">

  {* ----- Name row: firstname + lastname rendered together in 2 columns ----- *}
  {* When firstname is encountered first, the whole row (both fields) is output.  *}
  {* lastname is then skipped below to avoid a duplicate render.                  *}
  {elseif $_base === 'firstname' && $_has_name_row}
    {include file='_partials/form-fields-row.tpl'
      fields=[$formFields[$_key_firstname], $formFields[$_key_lastname]]
    }

  {elseif $_base === 'lastname' && $_has_name_row}
    {* Already rendered with firstname above *}

  {* ----- Location row: city + postcode (+ state if present) in 2 or 3 columns ----- *}
  {* Same pattern: city triggers the full row; postcode and id_state are skipped.      *}
  {elseif $_base === 'city' && $_has_city_row}
    {if $_has_state}
      {include file='_partials/form-fields-row.tpl'
        fields=[$formFields[$_key_city], $formFields[$_key_id_state], $formFields[$_key_postcode]]
      }
    {else}
      {include file='_partials/form-fields-row.tpl'
        fields=[$formFields[$_key_city], $formFields[$_key_postcode]]
      }
    {/if}

  {elseif $_base === 'postcode' && $_has_city_row}
    {* Already rendered with city above *}

  {elseif $_base === 'id_state' && $_has_city_row}
    {* Already rendered with city above *}

  {* ----- Default: any other field renders in a single full-width column ----- *}
  {else}
    {form_field field=$field}

  {/if}
{/foreach}


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
      data-bs-target="{if $prefix == 'invoice_'}#modal-invoice{else}#modal-delivery{/if}"
      data-type="edit"
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
    <button
      type="button"
      class="btn btn-outline-danger js-delete-address"
      data-id-address="{$address.id}"
      data-address-type="{if $prefix == 'invoice_'}invoice{else}delivery{/if}"
      title="{l s='Delete' d='Shop.Theme.Actions'}"
    >
      <i class="material-icons">delete</i> {l s='Delete' d='Shop.Theme.Actions'}
    </button>
  </div>
  <hr>
{/foreach}

<button
  type="button"
  class="btn btn-primary"
  data-bs-toggle="modal"
  data-bs-target="{if $prefix == 'invoice_'}#modal-invoice{else}#modal-delivery{/if}"
  data-type="create"
>
  {l s='Add new address' d='Shop.Theme.Actions'}
</button>
