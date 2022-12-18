import { LightningElement, wire } from "lwc";
import {
  MessageContext,
  subscribe,
  unsubscribe
} from "lightning/messageService";
import authenticate from "@salesforce/apex/SiteAuthController.authenticate";
import CUSTOMER_LOGGED_IN from "@salesforce/messageChannel/CustomerLoggedIn__c";
import CUSTOMER_LOGGED_OUT from "@salesforce/messageChannel/CustomerLoggedOut__c";

export default class SiteApp extends LightningElement {
  accountId = "";
  isAuthenticated = false;
  subscriptions = [];

  connectedCallback() {
    this.checkUser();
    this.initSubscriptions();
  }

  disconnectedCallback() {
    this.terminateSubscriptions();
  }

  @wire(MessageContext)
  messageContext;

  async checkUser() {
    const token = this.getToken();
    if (token) {
      try {
        const accountId = await authenticate({ token: token });
        this.setLoggedUserAccountId(accountId);
      } catch (error) {
        console.log(error);
        this.isAuthenticated = false;
      }
    }
  }

  setActivePage = (page) => {
    console.log(page);
    this.activePage = page;
  };

  setLoggedUserAccountId = (accountId) => {
    this.accountId = accountId;
    this.isAuthenticated = true;
  };

  resetLoggedUserAccountId = () => {
    this.accountId = "";
    this.isAuthenticated = false;
    this.removeToken();
  };

  removeToken() {
    localStorage.removeItem("b2b-token");
  }

  getToken() {
    return localStorage.getItem("b2b-token");
  }

  initSubscriptions() {
    this.initCustomerLoggedInSubscription();
    this.initCustomerLoggedOutSubscription();
  }

  terminateSubscriptions() {
    this.subscriptions.forEach((sub) => unsubscribe(sub));
  }

  initCustomerLoggedOutSubscription() {
    const sub = subscribe(
      this.messageContext,
      CUSTOMER_LOGGED_OUT,
      this.resetLoggedUserAccountId
    );
    this.subscriptions.push(sub);
  }

  initCustomerLoggedInSubscription() {
    const sub = subscribe(
      this.messageContext,
      CUSTOMER_LOGGED_IN,
      this.setLoggedUserAccountId
    );
    this.subscriptions.push(sub);
  }
}
