import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/features/digital_documents/cubits/digital_documents_cubit/digital_documents_cubit.dart';
import 'package:baladeyate/features/digital_documents/cubits/digital_documents_cubit/digital_documents_state.dart';
import 'package:baladeyate/features/digital_documents/presentation/components/digital_document_card.dart';
import 'package:baladeyate/features/digital_documents/presentation/components/digital_document_details_sheet.dart';
import 'package:baladeyate/features/digital_documents/presentation/components/digital_documents_empty_state.dart';
import 'package:baladeyate/features/digital_documents/presentation/components/digital_documents_error_state.dart';
import 'package:baladeyate/features/digital_documents/presentation/components/digital_documents_loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Screen UI for "Digital Documents" (الوثائق الرقمية) wallet.
class DigitalDocumentsScreen extends StatelessWidget {
  const DigitalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      BlocProvider.of<DigitalDocumentsCubit>(context);
      return const DigitalDocumentsView();
    } catch (_) {
      return BlocProvider(
        create: (context) =>
            sl<DigitalDocumentsCubit>()..fetchDigitalDocuments(),
        child: const DigitalDocumentsView(),
      );
    }
  }
}

class DigitalDocumentsView extends StatefulWidget {
  const DigitalDocumentsView({super.key});

  @override
  State<DigitalDocumentsView> createState() => _DigitalDocumentsViewState();
}

class _DigitalDocumentsViewState extends State<DigitalDocumentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DigitalDocumentsCubit>().fetchDigitalDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    const primaryDarkGreen = Color(0xFF1B5E20);

    return BlocListener<DigitalDocumentsCubit, DigitalDocumentsState>(
      listener: (context, state) {
        if (state is DigitalDocumentsError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الوثائق الرقمية',
            style: TextStyle(
              fontSize: 18.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryCharcoal,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.ic(context),
              color: AppColors.primaryCharcoal,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900.w(context)),
                child: RefreshIndicator(
                  color: primaryDarkGreen,
                  onRefresh: () => context
                      .read<DigitalDocumentsCubit>()
                      .fetchDigitalDocuments(),
                  child: BlocBuilder<DigitalDocumentsCubit,
                      DigitalDocumentsState>(
                    builder: (context, state) {
                      if (state is DigitalDocumentsLoading) {
                        return const DigitalDocumentsLoadingState();
                      }

                      if (state is DigitalDocumentsError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(horizontalPadding),
                            child: DigitalDocumentsErrorState(
                              message: state.message,
                              onRetry: () => context
                                  .read<DigitalDocumentsCubit>()
                                  .fetchDigitalDocuments(),
                            ),
                          ),
                        );
                      }

                      if (state is DigitalDocumentsSuccess) {
                        final documents = state.documents;

                        if (documents.isEmpty) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: DigitalDocumentsEmptyState(
                              onRefresh: () => context
                                  .read<DigitalDocumentsCubit>()
                                  .fetchDigitalDocuments(),
                              onSubmitNewTransaction: () =>
                                  context.push('/transactions/submit'),
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(horizontalPadding),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final document = documents[index];
                            return DigitalDocumentCard(
                              document: document,
                              cardIndex: index,
                              onTapDetails: () =>
                                  showDigitalDocumentDetailsSheet(
                                context,
                                document,
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
