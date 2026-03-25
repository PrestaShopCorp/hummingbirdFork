/**
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import {onePageCheckout} from '@constants/selectors-map';

/**
 * One Page Checkout — theme entry point
 *
 * The core (opc-form.js, opc-carrier-list.js, opc-carrier-select.js) owns
 * the full OPC lifecycle:
 *   - Form validation and pay button gating
 *   - Billing section toggle
 *   - Carrier list fetch, loader and error states
 *   - Cart summary and pay button amount update
 *
 * Add theme-specific behaviour here only — the core handles everything else.
 */

const initAddressSelection = (): void => {
  const {prestashop} = window;
  let abortController: AbortController | null = null;

  document.addEventListener('change', async (event) => {
    const target = event.target as HTMLInputElement;

    if (!target.matches(onePageCheckout.addressRadio)) {
      return;
    }

    const selectedAddressId = target.value;

    const allItems = document.querySelectorAll(onePageCheckout.addressItem);

    allItems.forEach((item) => {
      item.classList.remove('border-primary', 'selected');
    });

    const selectedItem = target.closest(onePageCheckout.addressItem);

    if (selectedItem) {
      selectedItem.classList.add('border-primary', 'selected');
    }

    const deliveryMethodsContainer = document.querySelector<HTMLElement>(onePageCheckout.deliveryMethods);

    if (!deliveryMethodsContainer) {
      return;
    }

    if (abortController) {
      abortController.abort();
    }

    abortController = new AbortController();

    const url = new URL(window.location.href);
    url.searchParams.set('ajax', '1');
    url.searchParams.set('action', 'opcCarriers');
    url.searchParams.set('id_address_delivery', selectedAddressId);

    const useSameAddress = document.querySelector<HTMLInputElement>(onePageCheckout.useSameAddress);

    if (useSameAddress?.checked) {
      url.searchParams.set('use_same_address', '1');
    }

    try {
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
        signal: abortController.signal,
      });

      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`);
      }

      const data = await response.json();

      if (data.delivery_options !== undefined) {
        prestashop.emit('opcCarriersUpdated', data);
      }

      deliveryMethodsContainer.dataset.idAddress = selectedAddressId;
    } catch (error) {
      // Ignore aborted requests (user clicked another address)
      if (error instanceof Error && error.name === 'AbortError') {
        return;
      }

      console.error('Failed to update delivery address:', error);
    }
  });
};

const initOnePageCheckout = (): void => {
  const {prestashop} = window;

  initAddressSelection();

  // Preserve Bootstrap accordion open state across cart summary DOM replacements.
  let openCollapseIds: string[] = [];

  prestashop.on('opcCartSummaryBeforeUpdate', ({selector}: {selector: string}) => {
    openCollapseIds = Array.from(document.querySelectorAll(`${selector} .accordion-collapse.show`))
      .map((el) => el.id)
      .filter(Boolean);
  });

  prestashop.on('opcCartSummaryUpdated', () => {
    openCollapseIds.forEach((id) => {
      const el = document.getElementById(id);

      if (!el) return;

      el.classList.add('show');

      const btn = document.querySelector(`[data-bs-target="#${id}"]`);

      if (btn) {
        btn.classList.remove('collapsed');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
    openCollapseIds = [];
  });
};

export default initOnePageCheckout;
