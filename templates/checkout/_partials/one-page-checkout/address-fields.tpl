{**
 * One Page Checkout - Address fields partial
 *}

{assign var="_has_name_row" value=isset($formFields.firstname) && isset($formFields.lastname)}
{assign var="_has_city_row" value=isset($formFields.city) && isset($formFields.postcode)}
{assign var="_has_state" value=isset($formFields.id_state)}

{foreach from=$formFields item="field"}
  {assign var="_base" value=$field.name}

  {if $_base === 'alias'}
    {form_field field=$field}

  {elseif $_base === 'firstname' && $_has_name_row}
    {include file='_partials/form-fields-row.tpl'
      fields=[$formFields.firstname, $formFields.lastname]
    }

  {elseif $_base === 'lastname' && $_has_name_row}
  {elseif $_base === 'city' && $_has_city_row}
    {if $_has_state}
      {include file='_partials/form-fields-row.tpl'
        fields=[$formFields.city, $formFields.id_state, $formFields.postcode]
      }
    {else}
      {include file='_partials/form-fields-row.tpl'
        fields=[$formFields.city, $formFields.postcode]
      }
    {/if}

  {elseif $_base === 'postcode' && $_has_city_row}
  {elseif $_base === 'id_state' && $_has_city_row}
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

  {else}
    {form_field field=$field}
  {/if}
{/foreach}
