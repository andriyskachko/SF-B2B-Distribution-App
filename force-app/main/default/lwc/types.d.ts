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
