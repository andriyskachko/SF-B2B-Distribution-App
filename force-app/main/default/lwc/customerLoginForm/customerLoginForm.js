import { LightningElement, wire } from "lwc";
import login from "@salesforce/apex/SiteAuthController.login";
import { publish, MessageContext } from "lightning/messageService";
import CUSTOMER_LOGGED_IN from "@salesforce/messageChannel/CustomerLoggedIn__c";

export default class CustomerLoginForm extends LightningElement {
  _accountId = "";
  login = "";
  password = "";
  error;

  @wire(MessageContext)
  messageContext;

  async handleLogin() {
    try {
      const [accountId, token] = await login({
        loginOrEmail: this.login,
        password: this.password
      });
      this.setLoggedUserAccountIdAndToken(accountId, token);
    } catch (error) {
      this.error = error.body.message;
    }
  }

  setLoggedUserAccountIdAndToken(accountId, token) {
    this._accountId = accountId;
    this.setToken(token);
    this.publishPayload();
  }

  get accountId() {
    return this._accountId;
  }

  setToken(value) {
    localStorage.setItem("b2b-token", value);
  }

  publishPayload() {
    const payload = {
      accountId: this._accountId
    };
    publish(this.messageContext, CUSTOMER_LOGGED_IN, payload);
  }

  handleLoginChange({ detail: { value } }) {
    this.login = value;
  }

  handlePasswordChange({ detail: { value } }) {
    this.password = value;
  }
}
