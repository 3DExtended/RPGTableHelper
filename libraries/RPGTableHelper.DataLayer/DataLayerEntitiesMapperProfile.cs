using System.Reflection.Emit;
using AutoMapper;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.Images;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer
{
    public class CustomTypeConverter
        : IValueConverter<ICollection<PermittedUsersToNotesBlock>?, IList<User.UserIdentifier>>
    {
        public IList<User.UserIdentifier> Convert(
            ICollection<PermittedUsersToNotesBlock>? source,
            ResolutionContext context
        )
        {
            if (source == null)
            {
                return new List<User.UserIdentifier>();
            }

            return source.Select(pu => User.UserIdentifier.From(pu.PermittedUserId)).ToList();
        }
    }

    public class DataLayerEntitiesMapperProfile : Profile
    {
        public DataLayerEntitiesMapperProfile()
        {
            CreateMapBetweenIdentifiers<NoteDocument.NoteDocumentIdentifier, Guid>();
            CreateMap<NoteDocument, NoteDocumentEntity>()
                .ForMember(x => x.NoteBlocks, opt => opt.MapFrom(src => src.NoteBlocks))
                .ReverseMap()
                .ForMember(x => x.NoteBlocks, opt => opt.MapFrom(src => src.NoteBlocks));

            CreateMap<NoteDocumentEntity, NoteDocumentEntity>().ReverseMap();

            CreateMap<NoteBlockModelBase, NoteBlockEntityBase>()
                .IncludeAllDerived()
                .ForMember(x => x.PermittedUsers, opt => opt.Ignore());

            CreateMap<NoteBlockEntityBase, NoteBlockModelBase>()
                .IncludeAllDerived()
                .ForMember(x => x.PermittedUsers, opt => opt.ConvertUsing(new CustomTypeConverter()));

            CreateMapBetweenIdentifiers<NoteBlockModelBase.NoteBlockModelBaseIdentifier, Guid>();
            CreateMap<TextBlock, TextBlockEntity>().ReverseMap();
            CreateMap<ImageBlock, ImageBlockEntity>().ReverseMap();

            CreateModelMaps<User, User.UserIdentifier, Guid, UserEntity>();
            CreateModelMaps<ImageMetaData, ImageMetaData.ImageMetaDataIdentifier, Guid, ImageMetaDataEntity>();

            CreateModelMaps<Campagne, Campagne.CampagneIdentifier, Guid, CampagneEntity>();
            CreateModelMaps<
                CampagneJoinRequest,
                CampagneJoinRequest.CampagneJoinRequestIdentifier,
                Guid,
                CampagneJoinRequestEntity
            >();

            CreateModelMaps<PlayerCharacter, PlayerCharacter.PlayerCharacterIdentifier, Guid, PlayerCharacterEntity>();

            CreateMap<Guid?, Option<Campagne.CampagneIdentifier>>()
                .ConvertUsing(
                    (tmid, _) => Option.From(tmid == null ? null : Campagne.CampagneIdentifier.From(tmid.Value))
                );
            CreateMap<Option<Campagne.CampagneIdentifier>, Guid?>()
                .ConvertUsing((tmid) => tmid.IsNone ? (Guid?)null : tmid.Get().Value);

            CreateOptionMapForType<SupportedSignInProviders>();
            CreateOptionMapForType<ImageType>();

            CreateModelMaps<
                OpenSignInProviderRegisterRequest,
                OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
                Guid,
                OpenSignInProviderRegisterRequestEntity
            >();

            // EncryptionChallenge Mappings
            CreateMapBetweenIdentifiers<EncryptionChallenge.EncryptionChallengeIdentifier, Guid>();
            CreateMap<EncryptionChallengeEntity, EncryptionChallengeEntity>();

            CreateMap<EncryptionChallenge, EncryptionChallengeEntity>()
                .ForMember(
                    dest => dest.UserId,
                    opt => opt.MapFrom(src => src.UserId.Match<Guid?>((some) => some.Value, () => null))
                )
                .ReverseMap()
                .ForMember(
                    dest => dest.UserId,
                    opt =>
                        opt.MapFrom(src =>
                            Option.From(
                                !src.UserId.HasValue ? null : new User.UserIdentifier { Value = src.UserId.Value }
                            )
                        )
                );

            // UserCredentials Mappings
            CreateMapBetweenIdentifiers<UserCredential.UserCredentialIdentifier, Guid>();
            CreateMap<UserCredential, UserCredentialEntity>()
                .ForMember(
                    dest => dest.EncryptionChallengeId,
                    opt => opt.MapFrom(src => src.EncryptionChallengeId.Match<Guid?>((some) => some.Value, () => null))
                )
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.EncryptionChallengeOfUser, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.UserId.Value))
                .ReverseMap()
                .ForMember(
                    dest => dest.UserId,
                    opt => opt.MapFrom(src => new User.UserIdentifier { Value = src.UserId })
                )
                .ForMember(
                    dest => dest.EncryptionChallengeId,
                    opt =>
                        opt.MapFrom(src =>
                            src.EncryptionChallengeId.ToOptionMapped(
                                (guid) => new EncryptionChallenge.EncryptionChallengeIdentifier { Value = guid }
                            )
                        )
                );
        }

        private void CreateOptionMapForType<T>()
            where T : struct
        {
            CreateMap<T?, Option<T>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<T>, T?>().ConvertUsing((tmid) => (T?)(tmid.IsNone ? null : tmid.Get()));
        }

        private void CreateModelMaps<TModel, TIdentifier, TIdentifierValue, TEntity>()
            where TModel : ModelBase<TIdentifier, TIdentifierValue>, new()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>();

            CreateMap<TModel, TEntity>().ReverseMap();
            CreateMap<TEntity, TEntity>().ReverseMap();
        }

        private void CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMap<TIdentifier, TIdentifierValue>().ConvertUsing((tmid, _) => tmid.Value);
            CreateMap<TIdentifierValue, TIdentifier>()
                .ConvertUsing((id, _) => Identifier<TIdentifierValue, TIdentifier>.From(id));
        }
    }
}
