<div
  id="address-modal"
  class="modal fade"
  tabindex="-1"
  role="dialog"
  aria-labelledby="address-modal-title"
  aria-hidden="true"
  data-title-new="{l s='New Delivery Address' d='Shop.Theme.Checkout'}"
  data-title-edit="{l s='Edit Delivery Address' d='Shop.Theme.Checkout'}"
>
  <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
    <div id="address-form-container" class="modal-content">
      <div class="modal-header pb-2">
        <h2 class="mb-0">Modal Header</h2>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <hr>
      <div class="modal-body">
        <div class="row">
          <input type="hidden" name="id_address" value="">
          <input type="hidden" name="token" value="{$token}">
          <input type="hidden" name="action" value="addressForm">
          <input type="hidden" name="submitAddress" value="1">
          {assign var="_key_alias" value="{$prefix}alias"}
          {assign var="_key_id_country" value="{$prefix}id_country"}
          {assign var="_key_firstname" value="{$prefix}firstname"}
          {assign var="_key_lastname" value="{$prefix}lastname"}
          {assign var="_key_company" value="{$prefix}company"}
          {assign var="_key_vat_number" value="{$prefix}vat_number"}
          {assign var="_key_address1" value="{$prefix}address1"}
          {assign var="_key_address2" value="{$prefix}address2"}
          {assign var="_key_city" value="{$prefix}city"}
          {assign var="_key_postcode" value="{$prefix}postcode"}
          {assign var="_key_id_state" value="{$prefix}id_state"}
          {assign var="_key_phone" value="{$prefix}phone"}


          {if isset($formFields[$_key_alias])}{form_field field=$formFields[$_key_alias]}{/if}

          {if isset($formFields[$_key_id_country])}{form_field field=$formFields[$_key_id_country]}{/if}

          {if isset($formFields[$_key_firstname]) && isset($formFields[$_key_lastname])}
            {include file='_partials/form-fields-row.tpl' fields=[$formFields[$_key_firstname], $formFields[$_key_lastname]]}
          {/if}

          {if isset($formFields[$_key_company])}{form_field field=$formFields[$_key_company]}{/if}

          {if isset($formFields[$_key_vat_number])}{form_field field=$formFields[$_key_vat_number]}{/if}

          {if isset($formFields[$_key_address1])}{form_field field=$formFields[$_key_address1]}{/if}

          {if isset($formFields[$_key_address2])}{form_field field=$formFields[$_key_address2]}{/if}

          {if isset($formFields[$_key_city]) && isset($formFields[$_key_postcode])}
            {if isset($formFields[$_key_id_state])}
              {include file='_partials/form-fields-row.tpl' fields=[$formFields[$_key_city], $formFields[$_key_id_state], $formFields[$_key_postcode]]}
            {else}
              {include file='_partials/form-fields-row.tpl' fields=[$formFields[$_key_city], $formFields[$_key_postcode]]}
            {/if}
          {/if}

          {if isset($formFields[$_key_phone])}{form_field field=$formFields[$_key_phone]}{/if}
        </div>
      </div>
      <div class="modal-footer">
        <button
          id="submit-address-modal"
          type="button"
          class="btn btn-primary"
          data-loading-text="{l s='Saving...' d='Shop.Theme.Checkout'}"
          data-text="{l s='Save' d='Shop.Theme.Actions'}"
        >
          {l s='Save' d='Shop.Theme.Actions'}
        </button>
      </div>
    </div>
  </div>
</div>
{literal}
  <script>
    /**
     * Initializes the address modal: dynamically updates the title
     * and pre-fills form fields based on whether the user is
     * creating a new address or editing an existing one.
     */
    document.addEventListener('DOMContentLoaded', () => {
      const addressModal = document.getElementById('address-modal');
      if (!addressModal) return;

      addressModal.addEventListener('show.bs.modal', (event) => {
        const button = event.relatedTarget;
        if (!button) return;

        const type = button.getAttribute('data-type');

        const modalTitle = addressModal.querySelector('.modal-header h2');
        if (modalTitle) {
          modalTitle.textContent = (type === 'edit')
            ? addressModal.getAttribute('data-title-edit')
            : addressModal.getAttribute('data-title-new');
        }

        const fields = [
          'id_address', 'alias', 'firstname', 'lastname',
          'company', 'vat_number', 'address1', 'address2',
          'city', 'postcode', 'id_state', 'id_country', 'phone'
        ];

        fields.forEach(field => {
          const input = addressModal.querySelector('[name$="' + field + '"]');
          if (input) {
            if (type === 'edit') {
              input.value = button.getAttribute('data-' + field) || '';
            } else {
              input.value = '';
            }
          }
        });
      });


      /**
       * Handles the AJAX form submission.
       */
      document.getElementById('submit-address-modal').addEventListener('click', function() {
        const container = document.getElementById('address-form-container');
        const saveBtn = this;

        const formData = new FormData();
        container.querySelectorAll('input, select').forEach(input => {
          formData.append(input.name, input.value);
        });

        saveBtn.disabled = true;
        saveBtn.innerHTML = saveBtn.getAttribute('data-loading-text');

        fetch(prestashop.urls.pages.address + '?ajax=1', {
          method: 'POST',
          body: formData,
          headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
          .then(res => res.json())
          .then(data => {
            if (data.success || !data.errors) {
              window.location.reload();
            } else {
              saveBtn.disabled = false;
              saveBtn.innerHTML = saveBtn.getAttribute('data-text');
            }
          })
          .catch(err => {
            console.error(err);
            saveBtn.disabled = false;
          });
      });
    });
  </script>
{/literal}
