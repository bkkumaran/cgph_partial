import { LightningElement, track } from 'lwc';
import requestOtp from '@salesforce/apex/EmailGateController.requestOtp';
import verifyOtp from '@salesforce/apex/EmailGateController.verifyOtp';

const TOKEN_KEY = 'email_gate_token';

export default class EmailGate extends LightningElement {
  @track email = '';
  @track otp = '';
  @track isBusy = false;
  @track error = '';
  @track showEmail = true;
  @track showOtp = false;

  onEmail(e) { this.email = e.detail.value; }
  onOtp(e) { this.otp = e.detail.value; }

  async sendCode() {
    this.error = '';
    this.isBusy = true;
    try {
      const token = await requestOtp({ email: this.email });
      sessionStorage.setItem(TOKEN_KEY, token);
      this.showEmail = false;
      this.showOtp = true;
    } catch (e) {
      this.error = e?.body?.message || 'Unable to send code.';
    } finally {
      this.isBusy = false;
    }
  }

  async verify() {
    this.error = '';
    this.isBusy = true;
    try {
      const token = sessionStorage.getItem(TOKEN_KEY);
      const ok = await verifyOtp({ token, otp: this.otp });
      if (ok) {
        this.dispatchEvent(new CustomEvent('verified'));
      } else {
        this.error = 'Invalid or expired code.';
      }
    } catch (e) {
      this.error = e?.body?.message || 'Verification failed.';
    } finally {
      this.isBusy = false;
    }
  }
}