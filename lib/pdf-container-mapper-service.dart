import 'rescue_container.dart';
import 'summary_container.dart';

List<SummaryContainer> mapForPdf(List<RescueContainer> container) =>
    container.map(_mapSingle).toList();

SummaryContainer _mapSingle(RescueContainer container) => SummaryContainer(
    container.id,
    container.name,
    "description",
    container.type.name,
    "value",
    "weight",
    "expirationDate",
    "dangerousGoods",
    "coldChain",
    container.moduleDestination ?? "",
    container.sequentialBuild.name);
