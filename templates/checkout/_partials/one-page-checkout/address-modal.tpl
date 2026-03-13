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

          <div class="form-fields-row form-fields-row--2" id="address-country-row">
            {if isset($formFields[$_key_city])}{form_field field=$formFields[$_key_city]}{/if}
            <div class="form-group mb-3" id="state-field-wrapper" style="{if !isset($formFields[$_key_id_state]) || empty($formFields[$_key_id_state].availableValues)}display: none;{/if}">
              <label class="form-label required" for="field-id_state">
                {l s='State' d='Shop.Forms.Labels'}
              </label>
              <select
                class="form-select"
                name="id_state"
                id="field-id_state"
                data-select-placeholder="{l s='-- please choose --' d='Shop.Forms.Labels' js=1}"
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
          </div>

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
    function initAddressManagement() {
      const addressModal = document.getElementById('address-modal');
      if (!addressModal) return;

      addressModal.addEventListener('hidden.bs.modal', () => {
        const container = document.getElementById('address-form-container');
        if (!container) return;

        container.querySelectorAll('.is-valid, .is-invalid').forEach(el => {
          el.classList.remove('is-valid', 'is-invalid');
        });
        container.querySelectorAll('.field-error').forEach(el => el.remove());
      });

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
        const skipValidation = ['postcode'];
        container.querySelectorAll('input, select').forEach(input => {
          if (input.type !== 'hidden' && !skipValidation.includes(input.name) && !input.checkValidity()) {
            isValid = false;
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
            container.querySelectorAll('.field-error').forEach(fieldError => fieldError.remove());
            container.querySelectorAll('.is-invalid').forEach(field => field.classList.remove('is-invalid'));

            if (data.errors && Object.keys(data.errors).length > 0) {

              container.querySelectorAll('input:not([type="hidden"]), select').forEach(input => {
                input.classList.remove('is-invalid');
                input.classList.add('is-valid');
              });

              for (const [fieldName, errors] of Object.entries(data.errors)) {
                const input = container.querySelector(`[name="${fieldName}"], [name$="${fieldName}"]`);
                if (input) {
                  input.classList.add('is-invalid');
                  const formGroup = input.closest('.form-group, .mb-3');
                  const errorHtml = `
                    <div class="field-error help-block">
                      <div class="alert alert-danger mt-2 alert-dismissible" role="alert">
                        ${errors.length > 1
                          ? `<ol class="mb-0">${errors.map(e => `<li>${e}</li>`).join('')}</ol>`
                          : errors[0]
                        }
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                      </div>
                    </div>
                  `;
                  if (formGroup) {
                    formGroup.insertAdjacentHTML('beforeend', errorHtml);
                  } else {
                    input.insertAdjacentHTML('afterend', errorHtml);
                  }
                }
              }
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

    function fetchStatesByCountry(countryId) {
      return fetch(`${prestashop.urls.pages.order}?ajax=1&action=getStatesByCountry&id_country=${countryId}`, {
        headers: {'X-Requested-With': 'XMLHttpRequest'}
      })
        .then(res => res.json())
        .catch(err => {
          console.error('Error fetching states:', err);
          return { hasStates: false, states: [] };
        });
    }

    function updateStateFieldUI(data) {
      const stateWrapper = document.getElementById('state-field-wrapper');
      const stateSelect = document.getElementById('field-id_state');
      const addressRow = document.getElementById('address-country-row');

      if (!stateWrapper || !stateSelect) return;

      if (data.hasStates && data.states.length > 0) {
        if (addressRow) {
          addressRow.classList.remove('form-fields-row--2');
          addressRow.classList.add('form-fields-row--3');
        }
        stateWrapper.style.display = '';
        const placeHolderSelect = stateSelect.getAttribute('data-select-placeholder');
        stateSelect.innerHTML = `<option value="">${placeHolderSelect}</option>`;
        data.states.forEach(state => {
          const option = document.createElement('option');
          option.value = state.id_state;
          option.textContent = state.name;
          stateSelect.appendChild(option);
        });
        stateSelect.required = true;
      } else {
        if (addressRow) {
          addressRow.classList.remove('form-fields-row--3');
          addressRow.classList.add('form-fields-row--2');
        }
        stateWrapper.style.display = 'none';
        stateSelect.required = false;
        stateSelect.value = '';
      }
    }

    function selectCountryState() {
      const addressModal = document.getElementById('address-modal');
      if (!addressModal) return;

      const countrySelect = addressModal.querySelector('[name$="id_country"]');
      if (!countrySelect || !countrySelect.value) return;

      fetchStatesByCountry(countrySelect.value).then(updateStateFieldUI);
    }

    function initCountryChangeHandler() {
      const addressModal = document.getElementById('address-modal');
      if (!addressModal) return;

      const countrySelect = addressModal.querySelector('[name$="id_country"]');
      if (!countrySelect) return;

      countrySelect.addEventListener('change', (event) => {
        const countryId = event.target.value;
        if (!countryId) return;

        fetchStatesByCountry(countryId).then(updateStateFieldUI);
      });
    }

    document.addEventListener('DOMContentLoaded', () => {
      const countryField = document.getElementById('field-id_country');
      if (countryField) {
        countryField.classList.remove('js-country');
      }
      initAddressManagement();
      initCountryChangeHandler();
      selectCountryState();
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
