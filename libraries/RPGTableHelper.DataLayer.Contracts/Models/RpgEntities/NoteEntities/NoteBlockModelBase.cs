using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities
{
    [KnownType(typeof(ImageBlock))]
    [KnownType(typeof(TextBlock))]
    public abstract class NoteBlockModelBase : NodeModelBase<NoteBlockModelBase.NoteBlockModelBaseIdentifier, Guid>
    {
        public bool IsDeleted { get; set; } = false;

        public NoteDocument.NoteDocumentIdentifier NoteDocumentId { get; set; } = default!;
        public User.UserIdentifier CreatingUserId { get; set; } = default!;

        public NotesBlockVisibility Visibility { get; set; }

        public IList<User.UserIdentifier> PermittedUsers { get; set; } = new List<User.UserIdentifier>();

        public record NoteBlockModelBaseIdentifier : Identifier<Guid, NoteBlockModelBaseIdentifier> { }
    }
}
