import '../db/request_dao.dart';
import '../db/waste_type_dao.dart';
import '../models/driver_dashboard_counts.dart';
import '../models/pickup_request.dart';
import '../models/user.dart';
import 'notification_service.dart';

/// Creates and loads pickup requests for clients and drivers.
class RequestService {
  RequestService({
    RequestDao? requestDao,
    WasteTypeDao? wasteTypeDao,
  })  : _requestDao = requestDao ?? RequestDao(),
        _wasteTypeDao = wasteTypeDao ?? WasteTypeDao();

  final RequestDao _requestDao;
  final WasteTypeDao _wasteTypeDao;

  Future<List<PickupRequest>> getClientRequests(int clientId) {
    return _requestDao.getByClientId(clientId);
  }

  Future<PickupRequest?> getRequest(int id) {
    return _requestDao.getById(id);
  }

  Future<List<PickupRequest>> getPendingForDriver(User driver) async {
    if (driver.serviceCityId == null) return [];
    return _requestDao.getPendingByServiceCity(driver.serviceCityId!);
  }

  Future<List<PickupRequest>> getActiveJobsForDriver(int driverId) {
    return _requestDao.getActiveByDriver(driverId);
  }

  Future<DriverDashboardCounts> getDriverDashboardCounts(User driver) async {
    if (driver.id == null || driver.serviceCityId == null) {
      return const DriverDashboardCounts(
        pending: 0,
        accepted: 0,
        completedToday: 0,
      );
    }
    return _requestDao.getDriverDashboardCounts(
      driverId: driver.id!,
      serviceCityId: driver.serviceCityId!,
    );
  }

  Future<({PickupRequest? request, String? error})> acceptRequest({
    required int requestId,
    required User driver,
  }) async {
    if (driver.id == null) {
      return (request: null, error: 'Driver account not found');
    }

    final rowsUpdated = await _requestDao.acceptRequest(
      requestId: requestId,
      driverId: driver.id!,
    );
    if (rowsUpdated == 0) {
      return (
        request: null,
        error: 'Request no longer available (already accepted or cancelled)',
      );
    }

    final saved = await _requestDao.getById(requestId);
    if (saved != null) {
      await NotificationService.instance.notifyStatusChange(saved);
    }
    return (request: saved, error: null);
  }

  Future<({PickupRequest? request, String? error})> advanceStatus({
    required int requestId,
    required User driver,
  }) async {
    if (driver.id == null) {
      return (request: null, error: 'Driver account not found');
    }

    final current = await _requestDao.getById(requestId);
    if (current == null) {
      return (request: null, error: 'Request not found');
    }
    if (current.driverId != driver.id) {
      return (request: null, error: 'This job is assigned to another driver');
    }

    String? nextStatus;
    String? expectedStatus;
    if (current.isAccepted) {
      expectedStatus = 'accepted';
      nextStatus = 'en_route';
    } else if (current.isEnRoute) {
      expectedStatus = 'en_route';
      nextStatus = 'completed';
    } else {
      return (request: null, error: 'Cannot update status from ${current.status}');
    }

    final rowsUpdated = await _requestDao.updateStatus(
      requestId: requestId,
      driverId: driver.id!,
      newStatus: nextStatus,
      expectedCurrentStatus: expectedStatus,
    );
    if (rowsUpdated == 0) {
      return (request: null, error: 'Status already changed');
    }

    final saved = await _requestDao.getById(requestId);
    if (saved != null) {
      await NotificationService.instance.notifyStatusChange(saved);
    }
    return (request: saved, error: null);
  }

  Future<({PickupRequest? request, String? error})> createRequest({
    required User client,
    required int wasteTypeId,
    required String size,
    required String preferredDate,
    required String preferredSlot,
    required String paymentMethod,
    required int cityId,
    required int districtId,
    int? streetId,
    String? landmarkNote,
    String? note,
  }) async {
    if (client.id == null) {
      return (request: null, error: 'Client account not found');
    }

    final wasteType = await _wasteTypeDao.getById(wasteTypeId);
    if (wasteType == null) {
      return (request: null, error: 'Invalid waste type');
    }

    final draft = PickupRequest(
      id: 0,
      clientId: client.id!,
      wasteTypeId: wasteTypeId,
      size: size,
      preferredDate: preferredDate,
      preferredSlot: preferredSlot,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      cityId: cityId,
      districtId: districtId,
      streetId: streetId,
      landmarkNote:
          landmarkNote?.trim().isEmpty == true ? null : landmarkNote?.trim(),
      status: 'pending',
      paymentMethod: paymentMethod,
      fee: wasteType.estFee,
    );

    final id = await _requestDao.insert(draft);
    final saved = await _requestDao.getById(id);
    return (request: saved, error: null);
  }
}
