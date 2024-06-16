import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DocumentModule = buildModule("DocumentModule", (m) => {
  const document = m.contract("Document", ['0xa797AE9B076b0dbDf48e83C9499Bad89F7370db5']);
  return { document };
});

export default DocumentModule;
