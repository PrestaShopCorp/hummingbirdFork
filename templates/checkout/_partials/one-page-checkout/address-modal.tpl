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

          {if isset($formFields[$_key_city])}{form_field field=$formFields[$_key_city]}{/if}

          <div class="form-group mb-3" id="state-field-wrapper" style="{if !isset($formFields[$_key_id_state]) || empty($formFields[$_key_id_state].availableValues)}display: none;{/if}">
            <label class="form-label" for="modal-field-id_state">
              {l s='State' d='Shop.Forms.Labels'}
            </label>
            <select
              class="form-select"
              name="id_state"
              id="modal-field-id_state"
            >
              <option value="">{l s='-- please choose --' d='Shop.Forms.Labels'}</option>
              {if isset($formFields[$_key_id_state]) && isset($formFields[$_key_id_state].availableValues)}
                {foreach from=$formFields[$_key_id_state].availableValues item="label" key="value"}
                  <option value="{$value}" {if $value eq $formFields[$_key_id_state].value}selected{/if}>{$label}</option>
                {/foreach}
              {/if}
            </select>
          </div>

          {if isset($formFields[$_key_postcode])}{form_field field=$formFields[$_key_postcode]}{/if}

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
<script>
  const ADDRESS_MODAL_TRANSLATIONS = {
    pleaseChoose: "{l s='-- please choose --' d='Shop.Forms.Labels' js=1}"
  };
</script>
{literal}
  <script>
    /**
     * Initializes the address modal: dynamically updates the title
     * and pre-fills form fields based on whether the user is
     * creating a new address or editing an existing one.
     */
    function initAddressManagement() {
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
      document.getElementById('submit-address-modal').addEventListener('click', function () {
        const container = document.getElementById('address-form-container');
        container.classList.add('was-validated');
        let isValid = true;

        const formData = new FormData();
        container.querySelectorAll('input, select').forEach(input => {
          if (input.type !== 'hidden' && !input.checkValidity()) {
            isValid = false;
          }
          // Skip 'action' field to avoid triggering addressForm refresh instead of save
          if (input.name === 'action') {
            return;
          }
          formData.append(input.name, input.value);
        });

        if (!isValid) {
          return;
        }

        const saveBtn = this;
        saveBtn.disabled = true;
        saveBtn.innerHTML = saveBtn.getAttribute('data-loading-text');

        fetch(prestashop.urls.pages.order + '?ajax=1&action=saveOpcAddress', {
          method: 'POST',
          body: formData,
          headers: {'X-Requested-With': 'XMLHttpRequest'}
        })
          .then(res => res.json())
          .then(data => {
            // Clear previous errors
            const existingAlert = container.querySelector('.alert-danger');
            if (existingAlert) existingAlert.remove();

            if (data.errors && data.errors.length > 0) {
              // Display validation errors
              const errorHtml = `
                <div class="alert alert-danger mt-3">
                  <ul class="mb-0">
                    ${data.errors.map(err => `<li>${err}</li>`).join('')}
                  </ul>
                </div>
              `;
              container.querySelector('.modal-body').insertAdjacentHTML('afterbegin', errorHtml);
              return;
            }

            if (data.success) {
              $(addressModal).modal('hide');
              renderLoadingState();
              refreshDOM();
            }
          })
          .catch(err => {
            console.error(err);
          })
          .finally(() => {
            saveBtn.disabled = false;
            saveBtn.innerHTML = saveBtn.getAttribute('data-text');
            container.classList.remove('was-validated');
          })
      });
    }

    function renderLoadingState() {
      const getSpinnerHTML = (text) => `
        <div class="spinner-container">
          <div class="spinner"></div>
          <span class="spinner-text">${text}</span>
        </div>
      `;

      const containerIds = [
        'opc-delivery-address',
        'opc-delivery-methods',
        'opc-payment-methods'
      ];

      containerIds.forEach(id => {
        const container = document.getElementById(id);
        if (container) {
          const loadingText = container.getAttribute('data-loading-text') || 'Loading...';
          container.innerHTML = getSpinnerHTML(loadingText);
        }
      });
    }

    function refreshDOM() {
      const formData = new FormData();
      formData.append('ajax', '1');
      formData.append('action', 'opcAddressesList');

      fetch(prestashop.urls.pages.order, {
        method: 'POST',
        body: formData,
      })
        .then(response => {
          return response.text();
        })
        .then(html => {
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, 'text/html');

          document.getElementById('opc-delivery-address').innerHTML = doc.body.innerHTML;
        })
        .catch(error => console.error(error));
    }


    function initCountryChangeHandler() {
      const addressModal = document.getElementById('address-modal');
      if (!addressModal) return;

      const countrySelect = addressModal.querySelector('[name$="id_country"]');
      if (!countrySelect) return;

      countrySelect.addEventListener('change', (event) => {
        const countryId = event.target.value;
        const stateWrapper = document.getElementById('state-field-wrapper');
        const stateSelect = document.getElementById('modal-field-id_state');

        if (!stateSelect || !stateWrapper) {
          console.error('State field not found in DOM');
          return;
        }

        if(!countryId) {
          console.error('No countryId')
          return;
        }

        fetch(`${prestashop.urls.pages.order}?ajax=1&action=getStatesByCountry&id_country=${countryId}`, {
          headers: {'X-Requested-With': 'XMLHttpRequest'}
        })
          .then(res => res.json())
          .then(data => {
            if (data.hasStates && data.states.length > 0) {
              stateWrapper.style.display = '';
              stateSelect.innerHTML = `<option value="">${ADDRESS_MODAL_TRANSLATIONS.pleaseChoose}</option>`;
              data.states.forEach(state => {
                const option = document.createElement('option');
                option.value = state.id_state;
                option.textContent = state.name;
                stateSelect.appendChild(option);
              });
              stateSelect.required = true;
            } else {
              stateWrapper.style.display = 'none';
              stateSelect.required = false;
              stateSelect.value = '';
            }
          })
          .catch(err => console.error('Error fetching states:', err));
      });
    }

    document.addEventListener('DOMContentLoaded', () => {
      const countryField = document.getElementById('field-id_country');
      if (countryField) {
        countryField.classList.remove('js-country');
      }
      initAddressManagement();
      initCountryChangeHandler();
    });
  </script>
{/literal}
{literal}
  <style>
    .spinner-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 60px 0;
    }

    .spinner {
      width: 40px;
      height: 40px;
      border: 4px solid #f3f3f3;
      border-top: 4px solid #0052cc;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-bottom: 15px;
    }

    .spinner-text {
      color: #555;
      font-family: inherit;
      font-size: 14px;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
{/literal}
