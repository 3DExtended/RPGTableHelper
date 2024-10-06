using Prodot.Patterns.Cqrs.EfCore;

namespace RPGTableHelper.DataLayer.Contracts.Models.BaseModels
{
    public class ModificationNode : NodeModelBase<ModificationNode.ModificationNodeIdentifier>
    {
        public string? IpAddress { get; set; }

        public DateTimeOffset? IpAddressRemovedAt { get; set; }

        public DateTimeOffset? IpSavedAt { get; set; }

        public record ModificationNodeIdentifier : Identifier<Guid, ModificationNodeIdentifier> { }
    }
}
