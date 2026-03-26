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

{assign var="_addresses_count" value=$customer.addresses|count}
{assign var="_show_inline_form" value=$_addresses_count == 0}
{if $prefix == 'invoice_' && !$use_same_address}
  {assign var="_show_inline_form" value=$_addresses_count < 2}
{/if}

{if !$_show_inline_form}
  {if isset($formFields[$prefix|cat:'id_address'])}
    <input type="hidden" name="{$formFields[$prefix|cat:'id_address'].name}" value="{$formFields[$prefix|cat:'id_address'].value}">
  {/if}
  {if $prefix == 'invoice_'}
    {if isset($formFields['id_address_invoice'])}
      <input type="hidden" name="{$formFields['id_address_invoice'].name}" value="{$formFields['id_address_invoice'].value}">
    {/if}
    {if isset($formFields['invoice_id_country'])}
      <input type="hidden" name="{$formFields['invoice_id_country'].name}" value="{$formFields['invoice_id_country'].value}">
    {/if}
  {elseif isset($formFields['id_country'])}
    <input type="hidden" name="{$formFields['id_country'].name}" value="{$formFields['id_country'].value}">
  {/if}
{/if}

{if $_show_inline_form}
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

    {* ----- Country: explicit select for OPC, without legacy js-country hook ----- *}
    {elseif $_base === 'id_country'}
      <div class="form-group mb-3">
        <label class="form-label{if $field.required} required{/if}" for="field-{$field.name}">
          {$field.label}
        </label>
        <select
          class="form-select"
          name="{$field.name}"
          id="field-{$field.name}"
          {if $field.required}required{/if}
        >
          <option value="">{l s='-- please choose --' d='Shop.Forms.Labels'}</option>
          {foreach from=$field.availableValues item="label" key="value"}
            <option value="{$value}" {if (string) $value === (string) $field.value}selected{/if}>{$label}</option>
          {/foreach}
        </select>
      </div>

    {* ----- Default: any other field renders in a single full-width column ----- *}
    {else}
      {form_field field=$field}

    {/if}
  {/foreach}
{elseif $_addresses_count > 0}
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
  {if $customer.addresses|count > 0}
    <button
      type="button"
      class="btn btn-primary"
      data-bs-toggle="modal"
      data-bs-target="{if $prefix == 'invoice_'}#modal-invoice{else}#modal-delivery{/if}"
      data-type="create"
    >
      {l s='Add new address' d='Shop.Theme.Actions'}
    </button>
  {/if}
{/if}
