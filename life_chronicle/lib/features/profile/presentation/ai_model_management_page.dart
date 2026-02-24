import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/config/ai_provider_templates.dart';
import '../../../core/utils/api_key_masker.dart';

class AiModelManagementPage extends ConsumerStatefulWidget {
  const AiModelManagementPage({super.key});

  @override
  ConsumerState<AiModelManagementPage> createState() => _AiModelManagementPageState();
}

class _AiModelManagementPageState extends ConsumerState<AiModelManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AI 模型管理',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF6366F1),
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  indicatorColor: const Color(0xFF6366F1),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  tabs: const [
                    Tab(text: '对话服务'),
                    Tab(text: 'Embedding 服务'),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProviderList(serviceType: 'chat'),
                _ProviderList(serviceType: 'embedding'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProviderDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('添加服务商', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddProviderDialog(BuildContext context) {
    final serviceType = _tabController.index == 0 ? 'chat' : 'embedding';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddProviderSheet(serviceType: serviceType),
    );
  }
}

class _ProviderList extends ConsumerWidget {
  const _ProviderList({required this.serviceType});

  final String serviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = serviceType == 'chat'
        ? ref.watch(allChatProvidersProvider)
        : ref.watch(allEmbeddingProvidersProvider);

    return providersAsync.when(
      data: (providers) {
        if (providers.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildProviderList(context, ref, providers);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_alt, size: 48, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无 AI 服务商',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击下方按钮添加您的第一个服务商',
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, WidgetRef ref, List<AiProvider> providers) {
    final activeProviderAsync = serviceType == 'chat'
        ? ref.watch(activeChatProviderProvider)
        : ref.watch(activeEmbeddingProviderProvider);

    return activeProviderAsync.when(
      data: (activeProvider) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final isActive = activeProvider?.id == provider.id;
            return _ProviderCard(
              provider: provider,
              isActive: isActive,
              onSetActive: () => _setActiveProvider(ref, provider),
              onEdit: () => _showEditDialog(context, provider),
              onDelete: () => _deleteProvider(context, ref, provider),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildProviderListSimple(context, ref, providers),
    );
  }

  Widget _buildProviderListSimple(BuildContext context, WidgetRef ref, List<AiProvider> providers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return _ProviderCard(
          provider: provider,
          isActive: provider.isActive,
          onSetActive: () => _setActiveProvider(ref, provider),
          onEdit: () => _showEditDialog(context, provider),
          onDelete: () => _deleteProvider(context, ref, provider),
        );
      },
    );
  }

  Future<void> _setActiveProvider(WidgetRef ref, AiProvider provider) async {
    final dao = ref.read(aiProviderDaoProvider);
    await dao.setActiveProvider(
      provider.id,
      provider.serviceType,
      now: DateTime.now(),
    );
  }

  void _showEditDialog(BuildContext context, AiProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProviderSheet(provider: provider),
    );
  }

  Future<void> _deleteProvider(BuildContext context, WidgetRef ref, AiProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除服务商"${provider.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dao = ref.read(aiProviderDaoProvider);
      await dao.deleteById(provider.id);
    }
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final AiProvider provider;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSetActive,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: isActive,
                  onChanged: (_) => onSetActive(),
                  activeColor: const Color(0xFF6366F1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ApiTypeBadge(apiType: provider.apiType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.modelName ?? '未设置模型',
                        style: TextStyle(
                          fontSize: 13,
                          color: provider.modelName != null
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        maskApiKey(provider.apiKey),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiTypeBadge extends StatelessWidget {
  const _ApiTypeBadge({required this.apiType});

  final String apiType;

  static const Map<String, (Color, Color)> _typeColors = {
    'openai': (Color(0xFF10B981), Color(0xFFD1FAE5)),
    'gemini': (Color(0xFF3B82F6), Color(0xFFDBEAFE)),
    'claude': (Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    'qwen': (Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    'zhipu': (Color(0xFF06B6D4), Color(0xFFCFFAFE)),
    'baichuan': (Color(0xFFEC4899), Color(0xFFFCE7F3)),
    'moonshot': (Color(0xFF6366F1), Color(0xFFE0E7FF)),
    'bge': (Color(0xFF84CC16), Color(0xFFECFCCB)),
    'custom': (Color(0xFF6B7280), Color(0xFFF3F4F6)),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _typeColors[apiType] ?? _typeColors['custom']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        apiType.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.$1,
        ),
      ),
    );
  }
}

class _AddProviderSheet extends ConsumerStatefulWidget {
  const _AddProviderSheet({required this.serviceType});

  final String serviceType;

  @override
  ConsumerState<_AddProviderSheet> createState() => _AddProviderSheetState();
}

class _AddProviderSheetState extends ConsumerState<_AddProviderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelNameController = TextEditingController();

  String _selectedApiType = 'openai';
  AiProviderTemplate? _selectedTemplate;
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  void _applyTemplate(AiProviderTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _nameController.text = template.name;
      _selectedApiType = template.apiType;
      _baseUrlController.text = template.baseUrl;
      _modelNameController.text = template.defaultModel;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(aiProviderDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    final existingProviders = widget.serviceType == 'chat'
        ? await ref.read(allChatProvidersProvider.future)
        : await ref.read(allEmbeddingProvidersProvider.future);
    final isFirst = existingProviders.isEmpty;

    await dao.upsert(AiProvidersCompanion(
      id: Value(id),
      name: Value(_nameController.text.trim()),
      apiType: Value(_selectedApiType),
      serviceType: Value(widget.serviceType),
      baseUrl: Value(_baseUrlController.text.trim()),
      apiKey: Value(_apiKeyController.text.trim()),
      modelName: Value(_modelNameController.text.trim().isEmpty ? null : _modelNameController.text.trim()),
      isActive: Value(isFirst),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final templates = widget.serviceType == 'chat'
        ? AiProviderTemplates.chatTemplates
        : AiProviderTemplates.embeddingTemplates;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '添加${widget.serviceType == 'chat' ? '对话' : 'Embedding'}服务商',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('快速选择模板', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          final isSelected = _selectedTemplate?.name == template.name;
                          return GestureDetector(
                            onTap: () => _applyTemplate(template),
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconForApiType(template.apiType),
                                    size: 24,
                                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    template.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF374151),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '服务商名称',
                        hintText: '如：DeepSeek、通义千问',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedApiType,
                      decoration: const InputDecoration(
                        labelText: 'API 类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'openai', child: Text('OpenAI 兼容')),
                        DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
                        DropdownMenuItem(value: 'claude', child: Text('Claude')),
                        DropdownMenuItem(value: 'qwen', child: Text('通义千问')),
                        DropdownMenuItem(value: 'zhipu', child: Text('智谱 AI')),
                        DropdownMenuItem(value: 'baichuan', child: Text('百川')),
                        DropdownMenuItem(value: 'moonshot', child: Text('月之暗面')),
                        DropdownMenuItem(value: 'bge', child: Text('BGE')),
                        DropdownMenuItem(value: 'custom', child: Text('自定义')),
                      ],
                      onChanged: (v) => setState(() => _selectedApiType = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        hintText: 'https://api.example.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? '请输入 Base URL' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _obscureApiKey,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        hintText: 'sk-xxxxxxxx',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? '请输入 API Key' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(
                        labelText: '模型名称（可选）',
                        hintText: '如：gpt-4、deepseek-chat',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForApiType(String apiType) {
    switch (apiType) {
      case 'openai':
        return Icons.smart_toy;
      case 'gemini':
        return Icons.auto_awesome;
      case 'claude':
        return Icons.psychology;
      case 'qwen':
        return Icons.cloud;
      case 'zhipu':
        return Icons.hub;
      case 'baichuan':
        return Icons.water;
      case 'moonshot':
        return Icons.nightlight;
      case 'bge':
        return Icons.view_in_ar;
      default:
        return Icons.settings;
    }
  }
}

class _EditProviderSheet extends ConsumerStatefulWidget {
  const _EditProviderSheet({required this.provider});

  final AiProvider provider;

  @override
  ConsumerState<_EditProviderSheet> createState() => _EditProviderSheetState();
}

class _EditProviderSheetState extends ConsumerState<_EditProviderSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelNameController;

  late String _selectedApiType;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _baseUrlController = TextEditingController(text: widget.provider.baseUrl);
    _apiKeyController = TextEditingController();
    _modelNameController = TextEditingController(text: widget.provider.modelName ?? '');
    _selectedApiType = widget.provider.apiType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(aiProviderDaoProvider);
    final now = DateTime.now();

    await dao.upsert(AiProvidersCompanion(
      id: Value(widget.provider.id),
      name: Value(_nameController.text.trim()),
      apiType: Value(_selectedApiType),
      serviceType: Value(widget.provider.serviceType),
      baseUrl: Value(_baseUrlController.text.trim()),
      apiKey: Value(_apiKeyController.text.trim().isEmpty ? widget.provider.apiKey : _apiKeyController.text.trim()),
      modelName: Value(_modelNameController.text.trim().isEmpty ? null : _modelNameController.text.trim()),
      isActive: Value(widget.provider.isActive),
      createdAt: Value(widget.provider.createdAt),
      updatedAt: Value(now),
    ));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('编辑服务商', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '服务商名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedApiType,
                      decoration: const InputDecoration(
                        labelText: 'API 类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'openai', child: Text('OpenAI 兼容')),
                        DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
                        DropdownMenuItem(value: 'claude', child: Text('Claude')),
                        DropdownMenuItem(value: 'qwen', child: Text('通义千问')),
                        DropdownMenuItem(value: 'zhipu', child: Text('智谱 AI')),
                        DropdownMenuItem(value: 'baichuan', child: Text('百川')),
                        DropdownMenuItem(value: 'moonshot', child: Text('月之暗面')),
                        DropdownMenuItem(value: 'bge', child: Text('BGE')),
                        DropdownMenuItem(value: 'custom', child: Text('自定义')),
                      ],
                      onChanged: (v) => setState(() => _selectedApiType = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? '请输入 Base URL' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _obscureApiKey,
                      decoration: InputDecoration(
                        labelText: 'API Key（留空保持不变）',
                        hintText: '输入新的 API Key',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前：${maskApiKey(widget.provider.apiKey)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(
                        labelText: '模型名称（可选）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
