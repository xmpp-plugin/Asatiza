import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/logic/certificate_file_rules.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/certificate_viewer_cubit.dart';
import '../bloc/certificate_viewer_state.dart';

/// The owner's certificate PDF, opened from teacher setup or Edit profile
/// (PHASE_005, decision 6). No artboard: built from [BackHeader] and
/// [EmptyStateView]. The PDF is downloaded with the user's session and kept
/// in memory only.
class CertificateViewerScreen extends StatelessWidget {
  const CertificateViewerScreen({required this.path, super.key});

  /// Storage path inside the `certificates` bucket.
  final String path;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificateViewerCubit>(
      create: (context) =>
          CertificateViewerCubit(context.read<MediaRepository>(), path)..load(),
      child: _CertificateViewerView(path: path),
    );
  }
}

class _CertificateViewerView extends StatefulWidget {
  const _CertificateViewerView({required this.path});

  final String path;

  @override
  State<_CertificateViewerView> createState() => _CertificateViewerViewState();
}

class _CertificateViewerViewState extends State<_CertificateViewerView> {
  static const CertificateFileRules _rules = CertificateFileRules();

  int? _page;
  int? _pages;

  /// The PDF could not be rendered (damaged file).
  bool _renderFailed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final name = _rules.displayName(widget.path);
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BackHeader(
              title: name.isEmpty ? l10n.certificateViewerTitle : name,
            ),
            Expanded(
              child:
                  BlocBuilder<CertificateViewerCubit, CertificateViewerState>(
                    builder: (context, state) {
                      final bytes = state.bytes;
                      if (state.status == CertificateViewerStatus.failure ||
                          _renderFailed) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space5),
                            child: EmptyStateView(
                              icon: AppIcon.document,
                              title: l10n.certificateOpenFailedTitle,
                              message: l10n.certificateOpenFailedMessage,
                              actionLabel: l10n.retryAction,
                              onAction: () {
                                setState(() => _renderFailed = false);
                                context.read<CertificateViewerCubit>().retry();
                              },
                            ),
                          ),
                        );
                      }
                      if (state.status == CertificateViewerStatus.loading ||
                          bytes == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colors.brand600,
                            semanticsLabel: l10n.loadingLabel,
                          ),
                        );
                      }
                      return Stack(
                        children: <Widget>[
                          PdfViewer.data(
                            bytes,
                            sourceName: widget.path,
                            params: PdfViewerParams(
                              backgroundColor: colors.surface100,
                              loadingBannerBuilder: (context, _, _) => Center(
                                child: CircularProgressIndicator(
                                  color: colors.brand600,
                                ),
                              ),
                              errorBannerBuilder: (context, _, _, _) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted && !_renderFailed) {
                                    setState(() => _renderFailed = true);
                                  }
                                });
                                return const SizedBox.shrink();
                              },
                              onViewerReady: (document, _) {
                                setState(() {
                                  _pages = document.pages.length;
                                  _page ??= 1;
                                });
                              },
                              onPageChanged: (page) {
                                if (page != null) {
                                  setState(() => _page = page);
                                }
                              },
                            ),
                          ),
                          if (_pages != null && _page != null)
                            PositionedDirectional(
                              bottom: AppSpacing.space4,
                              end: AppSpacing.space4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space3,
                                  vertical: AppSpacing.space1,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.ink.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Text(
                                  l10n.certificatePageIndicator(
                                    _page!,
                                    _pages!,
                                  ),
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.surface000,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
