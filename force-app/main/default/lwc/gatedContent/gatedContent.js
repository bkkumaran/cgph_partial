import { LightningElement, track } from 'lwc';
import isVerified from '@salesforce/apex/EmailGateController.isVerified';

const TOKEN_KEY = 'email_gate_token';

export default class GatedContent extends LightningElement {
  @track authorized = false;

  async connectedCallback() {
    const token = sessionStorage.getItem(TOKEN_KEY);
    if (!token) return;
    try {
      this.authorized = await isVerified({ token });
    } catch (e) {
      this.authorized = false;
    }
  }
}