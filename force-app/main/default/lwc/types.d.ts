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
