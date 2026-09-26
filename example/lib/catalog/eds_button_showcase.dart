import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

class EdsButtonShowcase extends StatelessWidget {
  const EdsButtonShowcase({super.key, this.embedsScrollView = true});

  final bool embedsScrollView;

  @override
  Widget build(BuildContext context) {
    if (embedsScrollView) {
      return SingleChildScrollView(child: _content(context));
    }
    return _content(context);
  }

  Widget _content(BuildContext context) {
    final tokens = context.edsTokens;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.xxl,
          children: <Widget>[
            _header(context),
            _presetSection(context),
            _emphasisToneMatrix(context),
            _sizeSection(context),
            _doneVsBadgeSection(context),
            _aliasEquivalenceSection(context),
            _newCapabilitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xs,
      children: <Widget>[
        Text(
          '按钮三维模型',
          style: tokens.typography.bodyStrong.copyWith(
            color: scheme.textPrimary,
          ),
        ),
        Text(
          '底层实现由 emphasis × tone × size 三个正交维度驱动；'
          'Role 是一张预设别名表，两者汇入同一份渲染实现。',
          style: tokens.typography.caption.copyWith(
            color: scheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    String? subtitle,
    Widget content,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.sm,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xxs,
            children: <Widget>[
              Text(
                title,
                style: tokens.typography.bodyStrong.copyWith(
                  color: scheme.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: tokens.typography.caption.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
            ],
          ),
          content,
        ],
      ),
    );
  }

  Widget _presetSection(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return _section(
      context,
      '预设入口 · Role',
      '一个角色 = 一组固定的三维组合。老代码写法与行为完全不变。',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.sm,
        children: <Widget>[
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: <Widget>[
              EdsButton('主要操作', action: () {}),
              EdsButton('次要操作', role: EdsButtonRole.secondary, action: () {}),
              EdsButton('轻量操作', role: EdsButtonRole.soft, action: () {}),
              EdsButton('危险操作', role: EdsButtonRole.danger, action: () {}),
              EdsButton('已完成', role: EdsButtonRole.done, action: () {}),
              EdsButton('零参数默认', action: () {}),
            ],
          ),
          Text(
            '最后一个未指定 role，走默认 .primary。'
            '这行能编译即证明三维初始化未产生重载歧义。',
            style: tokens.typography.caption.copyWith(
              color: scheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emphasisToneMatrix(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    const labelWidth = 64.0;
    const columnWidth = 96.0;
    return _section(
      context,
      '组合矩阵 · Emphasis × Tone',
      '改造前 4 种按钮只覆盖其中 4 格，其余格子旧模型无法表达。',
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.md,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: labelWidth),
                for (final tone in EdsButtonTone.values)
                  SizedBox(
                    width: columnWidth,
                    child: Text(
                      tone.name,
                      style: tokens.typography.caption.copyWith(
                        color: scheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            for (final emphasis in EdsButtonEmphasis.values)
              Row(
                children: <Widget>[
                  SizedBox(
                    width: labelWidth,
                    child: Text(
                      emphasis.name,
                      style: tokens.typography.caption.copyWith(
                        color: scheme.textSecondary,
                      ),
                    ),
                  ),
                  for (final tone in EdsButtonTone.values)
                    SizedBox(
                      width: columnWidth,
                      child: EdsButton.dimension(
                        '按钮',
                        emphasis: emphasis,
                        tone: tone,
                        action: () {},
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _sizeSection(BuildContext context) {
    final tokens = context.edsTokens;
    return _section(
      context,
      '尺寸档位 · Size',
      'regular 读取 controlSize.buttonHeight，与改造前完全一致；'
          '触屏档案下会自动放大到最小触控目标。',
      Wrap(
        spacing: tokens.spacing.md,
        runSpacing: tokens.spacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final size in EdsButtonSize.values)
            EdsButton.dimension(
              size.name,
              emphasis: EdsButtonEmphasis.filled,
              size: size,
              action: () {},
            ),
        ],
      ),
    );
  }

  Widget _doneVsBadgeSection(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    Widget caption(String text) => Text(
      text,
      style: tokens.typography.caption.copyWith(color: scheme.textSecondary),
    );
    Widget column(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xs,
      children: <Widget>[caption(label), child],
    );
    return _section(
      context,
      '可点击性验收 · .done vs EDSBadge',
      '按钮是实心绿 + ✓ + 34pt 高；徽章是浅绿胶囊且无交互。'
          '体量与色彩双重区分，不应再有误判。',
      Wrap(
        spacing: tokens.spacing.xxl,
        runSpacing: tokens.spacing.md,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: <Widget>[
          column(
            '按钮 · 可点击',
            EdsButton('已完成', role: EdsButtonRole.done, action: () {}),
          ),
          column(
            '徽章 · 不可点击',
            const EdsBadge('已完成', style: EdsBadgeStyle.success),
          ),
          column(
            '按钮 · 无图标对照',
            EdsButton.dimension(
              '已完成',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.success,
              action: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _aliasEquivalenceSection(BuildContext context) {
    final tokens = context.edsTokens;
    return _section(
      context,
      '别名等价性 · Role ↔ 三维',
      '每一行左右两侧应逐像素一致，用来证明别名表只是快捷方式，不是另一套实现。',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.md,
        children: <Widget>[
          _equivalenceRow(
            context,
            'primary',
            EdsButton('确定', action: () {}),
            EdsButton.dimension(
              '确定',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.accent,
              size: EdsButtonSize.regular,
              action: () {},
            ),
          ),
          _equivalenceRow(
            context,
            'secondary',
            EdsButton('取消', role: EdsButtonRole.secondary, action: () {}),
            EdsButton.dimension(
              '取消',
              emphasis: EdsButtonEmphasis.outline,
              tone: EdsButtonTone.accent,
              size: EdsButtonSize.regular,
              action: () {},
            ),
          ),
          _equivalenceRow(
            context,
            'soft',
            EdsButton('管理', role: EdsButtonRole.soft, action: () {}),
            EdsButton.dimension(
              '管理',
              emphasis: EdsButtonEmphasis.soft,
              tone: EdsButtonTone.accent,
              size: EdsButtonSize.regular,
              action: () {},
            ),
          ),
          _equivalenceRow(
            context,
            'danger',
            EdsButton('删除', role: EdsButtonRole.danger, action: () {}),
            EdsButton.dimension(
              '删除',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.danger,
              size: EdsButtonSize.regular,
              action: () {},
            ),
          ),
          _equivalenceRow(
            context,
            'done',
            EdsButton('已完成', role: EdsButtonRole.done, action: () {}),
            EdsButton.dimension(
              '已完成',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.success,
              size: EdsButtonSize.regular,
              systemImage: Icons.check,
              action: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _equivalenceRow(
    BuildContext context,
    String label,
    Widget lhs,
    Widget rhs,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      spacing: tokens.spacing.lg,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ),
        lhs,
        rhs,
      ],
    );
  }

  Widget _newCapabilitySection(BuildContext context) {
    final tokens = context.edsTokens;
    return _section(
      context,
      '改造解锁的典型场景',
      '这些组合在旧的一维模型里无解——不是设计上不需要，是模型说不出。',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.md,
        children: <Widget>[
          _capabilityRow(
            context,
            '对话框「忽略并删除」',
            '次要但危险，不抢主操作视觉',
            EdsButton.dimension(
              '忽略并删除',
              emphasis: EdsButtonEmphasis.soft,
              tone: EdsButtonTone.danger,
              action: () {},
            ),
          ),
          _capabilityRow(
            context,
            '卡片「更多」',
            '纯文字，最轻一档',
            EdsButton.dimension(
              '更多',
              emphasis: EdsButtonEmphasis.plain,
              tone: EdsButtonTone.accent,
              systemImage: Icons.more_horiz,
              action: () {},
            ),
          ),
          _capabilityRow(
            context,
            '工具栏密集操作',
            '28pt 小尺寸',
            EdsButton.dimension(
              '刷新',
              emphasis: EdsButtonEmphasis.outline,
              tone: EdsButtonTone.accent,
              size: EdsButtonSize.small,
              action: () {},
            ),
          ),
          _capabilityRow(
            context,
            '主行动区 CTA',
            '44pt 大尺寸',
            EdsButton.dimension(
              '开始处理',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.accent,
              size: EdsButtonSize.large,
              action: () {},
            ),
          ),
          _capabilityRow(
            context,
            '中性次要操作',
            '灰色实心，不抢主题色',
            EdsButton.dimension(
              '跳过',
              emphasis: EdsButtonEmphasis.filled,
              tone: EdsButtonTone.neutral,
              action: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _capabilityRow(
    BuildContext context,
    String title,
    String note,
    Widget action,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Wrap(
      spacing: tokens.spacing.lg,
      runSpacing: tokens.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xxs,
            children: <Widget>[
              Text(
                title,
                style: tokens.typography.caption.copyWith(
                  color: scheme.textPrimary,
                ),
              ),
              Text(
                note,
                style: tokens.typography.caption.copyWith(
                  color: scheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        action,
      ],
    );
  }
}
