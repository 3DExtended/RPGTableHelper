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

        /// <summary>
        /// Position in the document, set by the server: null until the document's blocks are arranged, then
        /// 0, 1, 2, ... Order blocks by <see cref="SortIndex"/> (null first), then by creation date.
        /// </summary>
        public int? SortIndex { get; set; }

        public NoteDocument.NoteDocumentIdentifier NoteDocumentId { get; set; } = default!;
        public User.UserIdentifier CreatingUserId { get; set; } = default!;

        public IList<User.UserIdentifier> PermittedUsers { get; set; } = new List<User.UserIdentifier>();

        public record NoteBlockModelBaseIdentifier : Identifier<Guid, NoteBlockModelBaseIdentifier> { }
    }
}
