import { LightningElement } from "lwc";
import login from "@salesforce/apex/SiteAuthController.login";
import authenticate from "@salesforce/apex/SiteAuthController.authenticate";

export default class CustomerLoginForm extends LightningElement {
  customerAssociatedAccount = "";
  login = "";
  password = "";

  connectedCallback() {}

  handleLogin() {
    login({ loginOrEmail: this.login, password: this.password }).then().catch();
    // Call SiteAuthController login method with current credentials
    // If it returns account and token ->
    // Set account id and call the custom event
    // Set the token to the cache and redirect to the main page
    // Create custom event User Logged in so the main app can set current account id

    this.handleCustomerLoggedIn();
  }

  handleCustomerLoggedIn() {
    // const customerLoggedInEvent = new CustomEvent(
    //   "customerloggedin",
    //   this.customerAssociatedAccount
    // );
    // call the event
  }

  handleAuth() {
    authenticate().then().catch();
    // Get the token from cache
    // Call Apex SiteAuthController authenticate method
    // If it returns account id => set accountId and redirect user to the main page
    // Otherwise do nothing

    this.handleCustomerLoggedIn();
  }

  handleLoginChange({ detail: { value } }) {
    this.login = value;
  }

  handlePasswordChange({ detail: { value } }) {
    this.password = value;
  }
}
