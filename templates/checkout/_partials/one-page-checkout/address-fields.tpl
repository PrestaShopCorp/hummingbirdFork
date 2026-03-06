{**
 * One Page Checkout - Address fields partial
 *
 * Renders address fields from $formFields.
 *
 * @param array $formFields - Form fields from OnePageCheckoutForm
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
 *}

{hook h='displayPersonalInformationTop' customer=$customer}

{include file='_partials/form-errors.tpl' errors=$errors['']}

{*
  Pass 1 — pre-compute which grouped rows are available.
  A row is only rendered if ALL its required fields exist; otherwise each field
  falls back to the default single-column rendering.
*}
{assign var="_has_name_row" value=isset($formFields['firstname']) && isset($formFields['lastname'])}
{assign var="_has_city_row" value=isset($formFields['city']) && isset($formFields['postcode'])}
{assign var="_has_state" value=isset($formFields['id_state'])}

<form id="opc-address-{$type}-form">
  {* Pass 2 — render each field, grouping into multi-column rows where applicable *}
  {foreach from=$formFields item="field"}
    {* ----- alias: always present but never displayed — emit as hidden input ----- *}
    {if $field.name === 'alias'}
      <input type="hidden" name="{$field.name}" value="My address">

    {* ----- Fields handled outside this partial (contact section, billing toggle) ----- *}
    {elseif $field.name === 'email' || $field.name === 'optin' || $field.name === 'use_same_address' || $field.name === 'id_address_invoice'}
      {* noop — rendered by the parent template *}

    {* ----- Name row: firstname + lastname rendered together in 2 columns ----- *}
    {* When firstname is encountered first, the whole row (both fields) is output.  *}
    {* lastname is then skipped below to avoid a duplicate render.                  *}
    {elseif $field.name === 'firstname' && $_has_name_row}
      {include file='_partials/form-fields-row.tpl'
        fields=[$formFields['firstname'], $formFields['lastname']]
      }

    {elseif $field.name === 'lastname' && $_has_name_row}
      {* Already rendered with firstname above *}

    {* ----- Location row: city + postcode (+ state if present) in 2 or 3 columns ----- *}
    {* Same pattern: city triggers the full row; postcode and id_state are skipped.      *}
    {elseif $field.name === 'city' && $_has_city_row}
      {if $_has_state}
        {include file='_partials/form-fields-row.tpl'
          fields=[$formFields['city'], $formFields['id_state'], $formFields['postcode']]
        }
      {else}
        {include file='_partials/form-fields-row.tpl'
          fields=[$formFields['city'], $formFields['postcode']]
        }
      {/if}

    {elseif $field.name === 'postcode' && $_has_city_row}
      {* Already rendered with city above *}

    {elseif $field.name === 'id_state' && $_has_city_row}
      {* Already rendered with city above *}

    {* ----- Default: any other field renders in a single full-width column ----- *}
    {else}
      {form_field field=$field}

    {/if}
  {/foreach}
</form>