/**
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
import {onePageCheckout as OpcMap} from '@constants/selectors-map';

let billingToggleHandler: ((e: Event) => void) | null = null;

const getForms = () => {
  return {
    customerForm: document.querySelector<HTMLFormElement>(OpcMap.customerForm),
    deliveryForm: document.querySelector<HTMLFormElement>(OpcMap.deliveryForm),
    invoiceForm: document.querySelector<HTMLFormElement>(OpcMap.invoiceForm),
  }
}

const initOnePageCheckout = () => {
  const {customerForm, deliveryForm, invoiceForm} = getForms();

  if (!customerForm || !deliveryForm || !invoiceForm) {
    return;
  }

  // Delegated listeners on the form (added once, survives DOM refreshes)
  onFormChange(customerForm, () => validateAllForms());
  onFormChange(deliveryForm, () => validateAllForms());
  onFormChange(invoiceForm, () => validateAllForms());

  initBillingToggle();
  validateAllForms();

  const {prestashop} = window;

  // Re-init after any address form refresh (country change or other)
  prestashop.on('updatedOpcAddressForm', () => {
    initBillingToggle();
    validateAllForms();
  });
};

const onFormChange = (form: HTMLFormElement, callback: () => void) => {
  form.addEventListener('input', callback);
  form.addEventListener('change', callback);
}

/**
 * Toggle billing address section visibility
 */
const initBillingToggle = () => {
  const checkbox = document.querySelector<HTMLInputElement>(OpcMap.useSameAddress);
  const billingSection = document.querySelector<HTMLElement>(OpcMap.billingSection);

  if (!checkbox || !billingSection) {
    return;
  }

  // Remove previous handler to avoid duplicates after DOM refresh
  if (billingToggleHandler) {
    checkbox.removeEventListener('change', billingToggleHandler);
  }

  billingToggleHandler = () => {
    billingSection.style.display = checkbox.checked ? 'none' : '';
    validateAllForms();
  };

  checkbox.addEventListener('change', billingToggleHandler);
};

const toggleDisabledPayButton = (value: boolean) => {
  const payButton = document.querySelector<HTMLButtonElement>(OpcMap.payButton);

  if (!payButton) {
    return;
  }

  payButton.disabled = value;
}

const validateAllForms = () => {
  const {customerForm, deliveryForm, invoiceForm} = getForms();

  if (!customerForm || !deliveryForm || !invoiceForm) {
    return;
  }

  const customerIsValid = validateForm(customerForm);
  const deliveryIsValid = validateForm(deliveryForm);

  const useSameAddress = document.querySelector<HTMLInputElement>(OpcMap.useSameAddress)

  const invoiceIsValid = useSameAddress?.checked ? true : validateForm(invoiceForm);
  toggleDisabledPayButton(customerIsValid && deliveryIsValid && invoiceIsValid)
}

/**
 * Check all visible required fields and toggle pay button
 */
const validateForm = (form: HTMLFormElement): boolean => {
  const requiredFields = form.querySelectorAll<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>(
    '[required]',
  );

  requiredFields.forEach((field) => {
    const isCheckbox = field instanceof HTMLInputElement && field.type === 'checkbox';
    const fieldIsValid = isCheckbox ? field.checked : Boolean(field.value?.trim());

    if (!fieldIsValid) {
      return false;
    }
  });
  return true;
};

export default initOnePageCheckout;
