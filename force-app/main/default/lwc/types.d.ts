interface DatatableColumn {
  label: string;
  fieldName: string;
  type: string;
  typeAttributes?: TypeAttributes;
  target?: string;
  sortable?: boolean;
}

interface TypeAttributes {
  label: Label;
}

interface Label {
  fieldName: string;
}

interface Account {
  id: string;
  name: string;
  url: string;
  lastActivityDate: Date;
}

interface ModalProp {
  fieldName: string;
  value: string;
  displayValue?: string;
}

interface Option {
  label: string;
  value: string;
}

interface UserDTO {
  id: string;
  name: string;
}

interface OpportunitiesSummaryDTO {
  accountId: string;
  accountName: string;
  accountUrl: string;
  totalQuantity: number;
  totalAmount: number;
}

interface TableHeader {
  id: string;
  name: string;
  prompt: string;
  width: number;
  align: string;
  padding: number;
}

interface FulfillmentRequestDTO {
  id: string;
  url: string;
  name: string;
}

interface ProductItemDTO {
  productItemId: string;
  productItemUrl: string;
  productId: string;
  productName: string;
  productUrl: string;
  productItemNumber: string;
  productItemQuantity: number;
  productItemSerialNumber: string;
}

interface OrderCartEntry extends ProductItemDTO {
  productListPrice: number;
}

interface ProductEntry {
  id: string;
  name: string;
  listPrice: number;
}

interface ProductEntryInCart extends ProductEntry {
  quantity: number;
}

interface OrderProduct {
  name: string;
  orderSummary: number;
  quantity: number;
}

interface OrderSummary {
  name: string;
  status: "Closed" | "In Progress" | "Cancelled";
  orderSummary: number;
  _children: OrderProduct[];
}
