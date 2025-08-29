import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hydration_session.dart';
import '../theme/design_constants.dart';
import '../utils/platform_utils.dart';

class SessionControls extends StatefulWidget {
  final HydrationSession? currentSession;
  final List<String> containers;
  final Function(String) onSessionStart;
  final Function(double) onSessionEnd;
  final VoidCallback onSessionCancel;
  final Function(String)? onSwitchContainer;

  const SessionControls({
    super.key,
    required this.currentSession,
    required this.containers,
    required this.onSessionStart,
    required this.onSessionEnd,
    required this.onSessionCancel,
    this.onSwitchContainer,
  });

  @override
  State<SessionControls> createState() => _SessionControlsState();
}

class _SessionControlsState extends State<SessionControls> {
  bool _readyToLog = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PlatformUtils.isDesktop(context)) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SessionControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset ready to log state when session changes
    if (widget.currentSession?.id != oldWidget.currentSession?.id) {
      _readyToLog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: PlatformUtils.isDesktop(context) ? _handleKeyEvent : null,
      child: Container(
        decoration: DesignConstants.cardDecoration,
        child: Padding(
          padding: EdgeInsets.all(
            PlatformUtils.isMobile(context) 
              ? DesignConstants.spacingL 
              : DesignConstants.spacingXXL
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignConstants.spacingS),
                  decoration: BoxDecoration(
                    color: DesignConstants.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignConstants.radiusS),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: DesignConstants.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignConstants.spacingM),
                Text(
                  'Session Control Panel',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: DesignConstants.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: DesignConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignConstants.spacingL),
            
            if (widget.currentSession == null)
              _buildStartSessionControls(context)
            else if (!_readyToLog)
              _buildActiveSessionControls(context)
            else
              _buildAmountSelectionControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartSessionControls(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    final isTablet = PlatformUtils.isTablet(context);
    final buttonPadding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : isTablet
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start drinking from:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        
        if (isDesktop)
          _buildDesktopContainerGrid(context, buttonPadding)
        else if (isTablet)
          _buildTabletContainerGrid(context, buttonPadding)
        else
          _buildMobileContainerWrap(context, buttonPadding),
          
        if (isDesktop) ...[
          const SizedBox(height: 12),
          Text(
            'Keyboard shortcuts: 1-${widget.containers.length.toString().split('').first} to select container, Enter to confirm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveSessionControls(BuildContext context) {
    final session = widget.currentSession!;
    final elapsed = DateTime.now().difference(session.startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final totalMinutes = elapsed.inMinutes;
    
    // Determine if session needs gentle reminder (45+ minutes)
    final needsReminder = totalMinutes >= 45;
    final isLongSession = totalMinutes >= 120; // 2+ hours

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: needsReminder ? [
                Colors.orange.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.05),
              ] : [
                DesignConstants.success.withValues(alpha: 0.1),
                DesignConstants.success.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignConstants.radiusM),
            border: Border.all(
              color: needsReminder 
                ? Colors.orange.withValues(alpha: 0.4)
                : DesignConstants.success.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    needsReminder ? Icons.schedule : Icons.local_drink,
                    color: needsReminder ? Colors.orange.shade600 : Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    needsReminder ? 'SESSION REMINDER' : 'DRINKING IN PROGRESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: needsReminder ? Colors.orange.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session.containerType,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  fontSize: DesignConstants.fontSubtitle + 2,
                  color: DesignConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target: ${session.targetMl.round()}ml',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    'Time: ${hours}h ${minutes}m',
                    style: TextStyle(
                      color: needsReminder ? Colors.orange.shade700 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Natural drinking encouragement message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DesignConstants.milkTeaBeige.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(DesignConstants.radiusS),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: DesignConstants.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getEncouragementTitle(totalMinutes),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignConstants.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getEncouragementMessage(totalMinutes),
                style: TextStyle(
                  color: DesignConstants.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Finished drinking button - primary action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _readyToLog = true;
              });
            },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(isLongSession ? "Finished drinking - let's log it" : "Finished drinking"),
            style: ElevatedButton.styleFrom(
              backgroundColor: needsReminder ? Colors.orange : DesignConstants.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: PlatformUtils.isDesktop(context) ? 18 : 16,
                horizontal: PlatformUtils.isDesktop(context) ? 24 : 16,
              ),
              textStyle: TextStyle(
                fontSize: PlatformUtils.isDesktop(context) ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary actions row
        PlatformUtils.isDesktop(context)
          ? _buildDesktopSecondaryActions(context)
          : _buildMobileSecondaryActions(context),
      ],
    );
  }

  String _getEncouragementTitle(int totalMinutes) {
    if (totalMinutes >= 120) {
      return 'Long session - that\'s okay!';
    } else if (totalMinutes >= 45) {
      return 'Take your time';
    } else if (totalMinutes >= 20) {
      return 'Good steady pace';
    } else {
      return 'Keep hydrating naturally';
    }
  }

  String _getEncouragementMessage(int totalMinutes) {
    if (totalMinutes >= 120) {
      return 'No rush! Some containers take time to finish. Drink at your natural pace.';
    } else if (totalMinutes >= 45) {
      return 'Perfect! This is exactly how hydration should work - natural and pressure-free.';
    } else if (totalMinutes >= 20) {
      return 'Great hydration habits! Sip throughout your activities when it feels right.';
    } else {
      return 'Drink naturally throughout your day. Log when you\'re finished with the container.';
    }
  }

  Widget _buildAmountSelectionControls(BuildContext context) {
    final session = widget.currentSession!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOGGING SESSION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session.containerType,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  fontSize: DesignConstants.fontSubtitle + 2,
                  color: DesignConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'How much did you drink from this container?',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        
        const SizedBox(height: 12),
        
        PlatformUtils.isDesktop(context)
          ? _buildDesktopAmountButtons(context, session)
          : _buildMobileAmountButtons(context, session),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCustomAmountDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: PlatformUtils.isDesktop(context) ? 14 : 12,
                  ),
                ),
                child: Text(
                  'Custom Amount',
                  style: TextStyle(
                    fontSize: PlatformUtils.isDesktop(context) ? 14 : 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _readyToLog = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: PlatformUtils.isDesktop(context) ? 14 : 12,
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: PlatformUtils.isDesktop(context) ? 14 : 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    double? customAmount;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Amount'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => customAmount = double.tryParse(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (customAmount != null && customAmount! > 0) {
                Navigator.of(context).pop();
                widget.onSessionEnd(customAmount!);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSwitchContainerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Container'),
        content: SizedBox(
          width: PlatformUtils.isDesktop(context) ? 400 : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a new container to switch to:'),
              const SizedBox(height: 16),
              if (PlatformUtils.isDesktop(context))
                ...widget.containers.asMap().entries.map((entry) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSwitchContainer!(entry.value);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.value),
                            Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...widget.containers.map((container) => 
                  ListTile(
                    title: Text(container),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onSwitchContainer!(container);
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle number keys for container selection when starting session
      if (widget.currentSession == null && !_readyToLog) {
        final keyLabel = event.logicalKey.keyLabel;
        if (keyLabel.isNotEmpty && RegExp(r'^[1-9]$').hasMatch(keyLabel)) {
          final index = int.parse(keyLabel) - 1;
          if (index < widget.containers.length) {
            widget.onSessionStart(widget.containers[index]);
            return KeyEventResult.handled;
          }
        }
      }
      
      // Handle Enter key for primary actions
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (widget.currentSession != null && !_readyToLog) {
          // Enter to finish drinking
          setState(() {
            _readyToLog = true;
          });
          return KeyEventResult.handled;
        } else if (_readyToLog) {
          // Enter to select 100% (most common)
          widget.onSessionEnd(widget.currentSession!.targetMl);
          return KeyEventResult.handled;
        }
      }
      
      // Handle Escape key to cancel
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (widget.currentSession != null) {
          if (_readyToLog) {
            setState(() {
              _readyToLog = false;
            });
          } else {
            widget.onSessionCancel();
          }
          return KeyEventResult.handled;
        }
      }

      // Handle percentage selection with number keys when logging
      if (_readyToLog && widget.currentSession != null) {
        final session = widget.currentSession!;
        switch (event.logicalKey.keyLabel) {
          case '1':
            widget.onSessionEnd(session.targetMl * 0.25);
            return KeyEventResult.handled;
          case '2':
            widget.onSessionEnd(session.targetMl * 0.5);
            return KeyEventResult.handled;
          case '3':
            widget.onSessionEnd(session.targetMl * 0.75);
            return KeyEventResult.handled;
          case '4':
          case '0':
            widget.onSessionEnd(session.targetMl);
            return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _buildDesktopContainerGrid(BuildContext context, EdgeInsets padding) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: widget.containers.length,
      itemBuilder: (context, index) {
        final container = widget.containers[index];
        return ElevatedButton(
          onPressed: () => widget.onSessionStart(container),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
            elevation: 0,
            padding: padding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(container, overflow: TextOverflow.ellipsis)),
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletContainerGrid(BuildContext context, EdgeInsets padding) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: widget.containers.length,
      itemBuilder: (context, index) {
        final container = widget.containers[index];
        return ElevatedButton(
          onPressed: () => widget.onSessionStart(container),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
            elevation: 0,
            padding: padding,
          ),
          child: Text(container, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }

  Widget _buildMobileContainerWrap(BuildContext context, EdgeInsets padding) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.containers.map((container) {
        return ElevatedButton(
          onPressed: () => widget.onSessionStart(container),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
            elevation: 0,
            padding: padding,
          ),
          child: Text(container),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopSecondaryActions(BuildContext context) {
    return Row(
      children: [
        if (widget.onSwitchContainer != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showSwitchContainerDialog(context),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Switch Container (S)',
                  style: TextStyle(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onSessionCancel,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel (Esc)', style: TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSecondaryActions(BuildContext context) {
    return Row(
      children: [
        if (widget.onSwitchContainer != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showSwitchContainerDialog(context),
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text('Switch'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onSessionCancel,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAmountButtons(BuildContext context, HydrationSession session) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onSessionEnd(session.targetMl * 0.25),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('25%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('(1)', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onSessionEnd(session.targetMl * 0.5),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('50%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('(2)', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onSessionEnd(session.targetMl * 0.75),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('75%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('(3)', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onSessionEnd(session.targetMl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('100%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('(4/0/Enter)', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Keyboard: 1=25%, 2=50%, 3=75%, 4/0/Enter=100%',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAmountButtons(BuildContext context, HydrationSession session) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onSessionEnd(session.targetMl * 0.25),
            child: const Text('25%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onSessionEnd(session.targetMl * 0.5),
            child: const Text('50%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onSessionEnd(session.targetMl * 0.75),
            child: const Text('75%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onSessionEnd(session.targetMl),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('100%'),
          ),
        ),
      ],
    );
  }
}