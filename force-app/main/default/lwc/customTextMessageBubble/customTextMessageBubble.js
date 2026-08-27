import { api, LightningElement } from "lwc";

const MESSAGE_CONTENT_CLASS = "embedded-messaging-message-content";
const ENDUSER = "EndUser";
const AGENT = "Agent";
const CHATBOT = "Chatbot";
const PARTICIPANT_TYPES = [ENDUSER, AGENT, CHATBOT];

export default class CustomTextMessageBubble extends LightningElement {
  @api configuration;
  @api conversationEntry;

  get sender() {
    return this.conversationEntry.sender && this.conversationEntry.sender.role;
  }

  get textContent() {
    try {
      const entryPayload = JSON.parse(this.conversationEntry.entryPayload);
      if (entryPayload.abstractMessage?.staticContent?.text) {
        return entryPayload.abstractMessage.staticContent.text;
      }
      return "";
    } catch (e) {
      console.error(e);
      return "";
    }
  }

  get generateMessageBubbleClassname() {
    if (this.isSupportedSender()) {
      return `${MESSAGE_CONTENT_CLASS} ${this.sender}`;
    } else {
      throw new Error(`Unsupported participant type passed in: ${this.sender}`);
    }
  }

  isSupportedSender() {
    return PARTICIPANT_TYPES.includes(this.sender);
  }
}