import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card_content.dart';

class AssignmentByContainerHeader extends ConsumerWidget {
  final RescueContainer container;

  AssignmentByContainerHeader(this.container);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContainerOverviewPageCardContent(container, 410);
  }
}
