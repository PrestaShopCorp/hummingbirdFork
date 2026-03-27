{**
 * OPC — Payment methods list partial (AJAX refresh)
 * Variables: $payment_options, $is_free, $selected_payment_module
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *}

{foreach from=$payment_options item="module_options"}
  {foreach from=$module_options item="option"}
    <div id="{$option.id}-container" class="payment-option">

      {* JS-enabled: radio + label *}
      <div class="payment-option__form-check form-check">
        <input
          class="payment-option__input form-check-input ps-shown-by-js{if $option.binary} binary{/if}"
          type="radio"
          name="payment-option"
          data-module-name="{$option.module_name}"
          id="{$option.id}"
          value="{$option.id}"
          {if ($selected_payment_module == $option.module_name || $is_free) || ($payment_options|@count === 1 && $module_options|@count === 1)} checked {/if}
        >
        <label class="payment-option__label form-check-label" for="{$option.id}">
          {if $option.logo}
            <img class="img-fluid" src="{$option.logo}" loading="lazy" alt="">
          {/if}
          {$option.call_to_action_text}
        </label>
      </div>

{* Additional information (hidden until selected) *}
      {if $option.additionalInformation}
        <div
          id="{$option.id}-additional-information"
          class="payment-option__additional-information js-additional-information"
          {if $option.module_name != $selected_payment_module}style="display: none;"{/if}
        >
          {$option.additionalInformation nofilter}
        </div>
      {/if}

      {* Payment form *}
      <div
        id="pay-with-{$option.id}-form"
        class="js-payment-option-form"
        {if $option.module_name != $selected_payment_module}style="display: none;"{/if}
      >
        {if $option.form}
          {$option.form nofilter}
        {else}
          <div class="js-opc-payment-fallback" data-action="{$option.action nofilter}">
            {foreach from=$option.inputs item=input}
              <input type="{$input.type}" name="{$input.name}" value="{$input.value}">
            {/foreach}
            <button style="display:none" id="pay-with-{$option.id}" type="button"></button>
          </div>
        {/if}
      </div>

    </div>
  {/foreach}
{foreachelse}
  <p class="alert alert-danger">
    {l s='Unfortunately, there are no payment method available.' d='Shop.Theme.Checkout'}
  </p>
{/foreach}
