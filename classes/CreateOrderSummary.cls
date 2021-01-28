public class CreateOrderSummary {
    @InvocableMethod(label='Create Order Summary')
    public static void createOrderSummary(List<String> orderIds) {
        for (ID orderId : orderIds) {
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId=orderIds.get(0);
            osir.orderLifeCycleType='UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }
    }
}