import { LightningElement, track } from 'lwc';
export default class PublicGateWrapper extends LightningElement {
  @track verified = false;
  handleVerified() { this.verified = true; }
}